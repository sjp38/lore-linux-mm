Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 180854405BD
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:00:23 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v184so193027144pgv.6
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:00:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d20si4818795plj.35.2017.02.15.13.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 13:00:21 -0800 (PST)
Date: Wed, 15 Feb 2017 13:00:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: testcases for RODATA: fix config dependency
Message-Id: <20170215130020.749e34e4d1e3d0789eb114f1@linux-foundation.org>
In-Reply-To: <CAGXu5jKofDhycUbLGMLNPM3LwjKuW1kGAbthSS1qufEB6bwOPA@mail.gmail.com>
References: <20170209131625.GA16954@pjb1027-Latitude-E5410>
	<CAGXu5jKofDhycUbLGMLNPM3LwjKuW1kGAbthSS1qufEB6bwOPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jinbum Park <jinb.park7@gmail.com>, Valentin Rothberg <valentinrothberg@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>

On Fri, 10 Feb 2017 15:36:37 -0800 Kees Cook <keescook@chromium.org> wrote:

> >  config DEBUG_RODATA_TEST
> >      bool "Testcase for the marking rodata read-only"
> > -    depends on DEBUG_RODATA
> > +    depends on STRICT_KERNEL_RWX
> >      ---help---
> >        This option enables a testcase for the setting rodata read-only.
> 
> Great, thanks!
> 
> Acked-by: Kees Cook <keescook@chromium.org>
> 
> Andrew, do you want to take this patch, since it applies on top of
> "mm: add arch-independent testcases for RODATA", or do you want me to
> take both patches into my KSPP tree which has the DEBUG_RODATA ->
> STRICT_KERNEL_RWX renaming series?

I staged this and mm-add-arch-independent-testcases-for-rodata.patch
after linux-next and shall merge them after the STRICT_KERNEL_RWX
rename has gone into mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
