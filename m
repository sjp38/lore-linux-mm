Received: by el-out-1112.google.com with SMTP id y26so1329241ele.4
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 13:44:11 -0700 (PDT)
From: Nitin Gupta <nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Subject: Re: [PATCH 2/6] compcache: block device - internal defs
Date: Tue, 25 Mar 2008 02:09:27 +0530
References: <200803242033.30782.nitingupta910@gmail.com> <4cefeab80803241050y1ee7c22fi73234f24e65f958a@mail.gmail.com> <87a5b0800803241336u547e0f39j277a8857ce674403@mail.gmail.com>
In-Reply-To: <87a5b0800803241336u547e0f39j277a8857ce674403@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803250209.28332.nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Will Newton <will.newton@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 25 March 2008 02:06:02 am Will Newton wrote:
> On Mon, Mar 24, 2008 at 5:50 PM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> >  >  >  +
> >  >  >  +/* Create /proc/compcache? */
> >  >  >  +/* If STATS is disabled, this will give minimal compcache info */
> >  >  >  +#define CONFIG_COMPCACHE_PROC
> >  >  >  +
> >  >  >  +#if DEBUG
> >  >  >  +#define CC_DEBUG(fmt,arg...) \
> >  >  >  +       printk(KERN_DEBUG C fmt,##arg)
> >  >  >  +#else
> >  >  >  +#define CC_DEBUG(fmt,arg...) NOP
> >  >  >  +#endif
> >  >
> >  >  Have you thought about using pr_debug() for this? It looks like it
> >  >  would simplify this file at the cost of a little flexibility.
> >  >
> >
> >  I want to enable/disable this debugging based on DEBUG_COMPCACHE flag.
> >  Thats why I added these macros. I will do 'printk(KERN_DEBUG' ->
> >  pr_debug
> 
> The definition of pr_debug (kernel.h) is already surrounded by #ifdef
> DEBUG so it may give you the same behaviour as the CC_DEBUG macro.
> 

Yes, I missed this point. But still, I want to have two levels of debugging. I can probably use pr_debug() for "normal" debug and CC_DEBUG for "verbose" debugging. This looks bit inconsistent, so maybe I should stick which CC_DEBUG/CC_DEBUG2 pair instead?

- Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
