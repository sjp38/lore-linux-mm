Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 677096B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 20:09:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j186so18028527pge.12
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 17:09:34 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id 72si266448ple.107.2017.07.06.17.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 17:09:33 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id c73so8412583pfk.2
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 17:09:33 -0700 (PDT)
Subject: Re: [PATCH 1/4] kasan: support alloca() poisoning
References: <20170706220114.142438-1-ghackmann@google.com>
 <20170706220114.142438-2-ghackmann@google.com>
From: Greg Hackmann <ghackmann@google.com>
Message-ID: <504eb5d1-d505-46fe-86aa-5b2d01497c15@google.com>
Date: Thu, 6 Jul 2017 17:09:31 -0700
MIME-Version: 1.0
In-Reply-To: <20170706220114.142438-2-ghackmann@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>

On 07/06/2017 03:01 PM, Greg Hackmann wrote:
> @@ -101,6 +101,9 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
>   		break;
>   	case KASAN_USE_AFTER_SCOPE:
>   		bug_type = "use-after-scope";
> +	case KASAN_ALLOCA_LEFT:
> +	case KASAN_ALLOCA_RIGHT:
> +		bug_type = "alloca-out-of-bounds";
>   		break;
>   	}

There needs to be a "break" above the new case statements.  I'll wait to 
see if there's any other feedback, then send out a V2 patch that fixes this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
