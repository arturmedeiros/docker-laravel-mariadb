<?php

namespace App\Providers;

use App\Models\User;
use App\Observers\UserUuidObserver;
use Illuminate\Routing\UrlGenerator;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(UrlGenerator $url): void
    {
        Schema::defaultStringLength(255);

        if (getenv('APP_ENV') == "production") {
            $url->forceScheme('https');
            $this->app['request']->server->set('HTTPS', 'on');
        }

        // Adiciona UUID exclusivo ao usuário
        User::observe(UserUuidObserver::class);
    }
}
