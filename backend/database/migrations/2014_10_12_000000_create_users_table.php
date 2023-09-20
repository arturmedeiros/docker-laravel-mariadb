<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->longText('uuid');
            $table->string('name')->nullable();
            $table->string('email')->unique();
            // Others
            $table->longText('avatar')->nullable();
            $table->string('phone')->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('phone_verified_at')->nullable();
            $table->string('password');
            $table->longText('preferences')->nullable();
            $table->integer('role_key')->unsigned()->default(0);
            $table->integer('status_key')->unsigned()->nullable()->default(1);
            $table->longText('recovery_token')->nullable();
            $table->rememberToken();
            $table->timestamps();
            // SoftDeletes
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
