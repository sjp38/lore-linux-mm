Received: by py-out-1112.google.com with SMTP id f47so2810257pye.20
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 13:36:03 -0700 (PDT)
Message-ID: <87a5b0800803241336u547e0f39j277a8857ce674403@mail.gmail.com>
Date: Mon, 24 Mar 2008 20:36:02 +0000
From: "Will Newton" <will.newton@gmail.com>
Subject: Re: [PATCH 2/6] compcache: block device - internal defs
In-Reply-To: <4cefeab80803241050y1ee7c22fi73234f24e65f958a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803242033.30782.nitingupta910@gmail.com>
	 <87a5b0800803240905g705a8ea3p11c415ad37fc3cbb@mail.gmail.com>
	 <4cefeab80803241050y1ee7c22fi73234f24e65f958a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta910@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 5:50 PM, Nitin Gupta <nitingupta910@gmail.com> wrote:
>  >  >  +
>  >  >  +/* Create /proc/compcache? */
>  >  >  +/* If STATS is disabled, this will give minimal compcache info */
>  >  >  +#define CONFIG_COMPCACHE_PROC
>  >  >  +
>  >  >  +#if DEBUG
>  >  >  +#define CC_DEBUG(fmt,arg...) \
>  >  >  +       printk(KERN_DEBUG C fmt,##arg)
>  >  >  +#else
>  >  >  +#define CC_DEBUG(fmt,arg...) NOP
>  >  >  +#endif
>  >
>  >  Have you thought about using pr_debug() for this? It looks like it
>  >  would simplify this file at the cost of a little flexibility.
>  >
>
>  I want to enable/disable this debugging based on DEBUG_COMPCACHE flag.
>  Thats why I added these macros. I will do 'printk(KERN_DEBUG' ->
>  pr_debug

The definition of pr_debug (kernel.h) is already surrounded by #ifdef
DEBUG so it may give you the same behaviour as the CC_DEBUG macro.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
