Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4566B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 20:20:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v12-v6so3354445wmc.1
        for <linux-mm@kvack.org>; Mon, 07 May 2018 17:20:20 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 35-v6si14018024wry.155.2018.05.07.17.20.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 17:20:19 -0700 (PDT)
Subject: Re: [PATCH] mm: expland documentation over __read_mostly
References: <20180507231506.4891-1-mcgrof@kernel.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <e2aa9491-c1e3-4ae1-1ab2-589a6642a24a@infradead.org>
Date: Mon, 7 May 2018 17:20:09 -0700
MIME-Version: 1.0
In-Reply-To: <20180507231506.4891-1-mcgrof@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>, tglx@linutronix.de, arnd@arndb.de, cl@linux.com
Cc: keescook@chromium.org, luto@amacapital.net, longman@redhat.com, viro@zeniv.linux.org.uk, willy@infradead.org, ebiederm@xmission.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/07/2018 04:15 PM, Luis R. Rodriguez wrote:
> __read_mostly can easily be misused by folks, its not meant for
> just read-only data. There are performance reasons for using it, but
> we also don't provide any guidance about its use. Provide a bit more
> guidance over it use.
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
>  include/linux/cache.h | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> Every now and then we get a patch suggesting to use __read_mostly for
> something new or old but with no justifications. Add a bit more
> verbiage to help guide its users.
> 
> Is this sufficient documentation to at least ask for a reason in the commit
> log as to why its being used for new entries? Or should we be explicit and
> ask for such justifications in commit logs? Taken from prior discussions
> with Christoph Lameter [0] over its use.
> 
> [0] https://lkml.kernel.org/r/alpine.DEB.2.11.1504301343190.28879@gentwo.org
> 
> diff --git a/include/linux/cache.h b/include/linux/cache.h
> index 750621e41d1c..62bc5adc0ed5 100644
> --- a/include/linux/cache.h
> +++ b/include/linux/cache.h
> @@ -15,8 +15,14 @@
>  
>  /*
>   * __read_mostly is used to keep rarely changing variables out of frequently
> - * updated cachelines. If an architecture doesn't support it, ignore the
> - * hint.
> + * updated cachelines. Its use should be reserved for data that is used
> + * frequently in hot paths. Performance traces can help decide when to use
> + * this. You want __read_mostly data to be tightly packed, so that in the
> + * best case multiple frequently read variables for a hot path will be next
> + * to each other in order to reduce the number of cachelines needed to
> + * execute a critial path. We should be mindful and selective if its use.

                                                                 of its use.

> + *
> + * If an architecture doesn't support it, ignore the hint.
>   */
>  #ifndef __read_mostly
>  #define __read_mostly
> 

-- 
~Randy
