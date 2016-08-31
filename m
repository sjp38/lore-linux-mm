Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C46D6B0038
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 22:07:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so78615243pfg.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 19:07:25 -0700 (PDT)
Received: from mail-pf0-x23f.google.com (mail-pf0-x23f.google.com. [2607:f8b0:400e:c00::23f])
        by mx.google.com with ESMTPS id q11si47967772pfd.42.2016.08.30.19.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 19:07:24 -0700 (PDT)
Received: by mail-pf0-x23f.google.com with SMTP id i64so22670457pfg.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 19:07:24 -0700 (PDT)
Date: Tue, 30 Aug 2016 19:07:23 -0700 (PDT)
From: amanda4ray@gmail.com
Message-Id: <2a6c69fa-fe05-40c4-b817-15a58ed2666b@googlegroups.com>
In-Reply-To: <5775232B.2070607@virtuozzo.com>
References: <1467294357-98002-1-git-send-email-dvyukov@google.com>
 <5775232B.2070607@virtuozzo.com>
Subject: Re: [PATCH] kasan: add newline to messages
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5683_850624218.1472609243570"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kasan-dev <kasan-dev@googlegroups.com>
Cc: dvyukov@google.com, akpm@linux-foundation.org, glider@google.com, linux-mm@kvack.org, aryabinin@virtuozzo.com

------=_Part_5683_850624218.1472609243570
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On Thursday, June 30, 2016 at 9:47:33 AM UTC-4, Andrey Ryabinin wrote:
> On 06/30/2016 04:45 PM, Dmitry Vyukov wrote:
> > Currently GPF messages with KASAN look as follows:
> > kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> > Add newlines.
> > 
> > Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> 
> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> 
> > ---
> >  arch/x86/mm/kasan_init_64.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> > index 1b1110f..0493c17 100644
> > --- a/arch/x86/mm/kasan_init_64.c
> > +++ b/arch/x86/mm/kasan_init_64.c
> > @@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block *self,
> >  			     void *data)
> >  {
> >  	if (val == DIE_GPF) {
> > -		pr_emerg("CONFIG_KASAN_INLINE enabled");
> > -		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access");
> > +		pr_emerg("CONFIG_KASAN_INLINE enabled\n");
> > +		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access\n");
> >  	}
> >  	return NOTIFY_OK;
> >  }
> >

On Thursday, June 30, 2016 at 9:47:33 AM UTC-4, Andrey Ryabinin wrote:
> On 06/30/2016 04:45 PM, Dmitry Vyukov wrote:
> > Currently GPF messages with KASAN look as follows:
> > kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> > Add newlines.
> > 
> > Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> 
> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> 
> > ---
> >  arch/x86/mm/kasan_init_64.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> > index 1b1110f..0493c17 100644
> > --- a/arch/x86/mm/kasan_init_64.c
> > +++ b/arch/x86/mm/kasan_init_64.c
> > @@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block *self,
> >  			     void *data)
> >  {
> >  	if (val == DIE_GPF) {
> > -		pr_emerg("CONFIG_KASAN_INLINE enabled");
> > -		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access");
> > +		pr_emerg("CONFIG_KASAN_INLINE enabled\n");
> > +		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access\n");
> >  	}
> >  	return NOTIFY_OK;
> >  }
> >


------=_Part_5683_850624218.1472609243570--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
