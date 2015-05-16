Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC246B0071
	for <linux-mm@kvack.org>; Sat, 16 May 2015 13:09:29 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so20593165igb.0
        for <linux-mm@kvack.org>; Sat, 16 May 2015 10:09:29 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0247.hostedemail.com. [216.40.44.247])
        by mx.google.com with ESMTP id u35si4749573iou.22.2015.05.16.10.09.28
        for <linux-mm@kvack.org>;
        Sat, 16 May 2015 10:09:28 -0700 (PDT)
Message-ID: <1431796166.15709.81.camel@perches.com>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
From: Joe Perches <joe@perches.com>
Date: Sat, 16 May 2015 10:09:26 -0700
In-Reply-To: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
References: 
	<CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: dhowells@redhat.com, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs@redhat.com, linux-afs@lists.infradead.org

On Sat, 2015-05-16 at 20:01 +0300, Leon Romanovsky wrote:
> Dear David,
> 
> During my work on NOMMU system (mm/nommu.c), I saw definition and
> usage of kenter/kleave/kdebug macros. These macros are compiled as
> empty because of "#if 0" construction.
>   45 #if 0
>   46 #define kenter(FMT, ...) \
>   47         printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
>   48 #define kleave(FMT, ...) \
>   49         printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
>   50 #define kdebug(FMT, ...) \
>   51         printk(KERN_DEBUG "xxx" FMT"yyy\n", ##__VA_ARGS__)
>   52 #else
>   53 #define kenter(FMT, ...) \
>   54         no_printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
>   55 #define kleave(FMT, ...) \
>   56         no_printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
>   57 #define kdebug(FMT, ...) \
>   58         no_printk(KERN_DEBUG FMT"\n", ##__VA_ARGS__)
>   59 #endif
[]
> My question is how we should handle such duplicated debug print code?
> As possible solutions, I see five options:
> 1. Leave it as is.
> 2. Move it to general include file (for example linux/printk.h) and
> commonize the output to be consistent between different kdebug users.
> 3. Add CONFIG_*_DEBUG definition for every kdebug user.
> 4. Move everything to "#if 0" construction.
> 5. Move everything to "#if defined(__KDEBUG)" construction.

6: delete the macros and uses


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
