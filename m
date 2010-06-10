Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 309796B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 07:21:19 -0400 (EDT)
Subject: Re: [PATCH -mm] only drop root anon_vma if not self
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTin9UTy3qSWJ8u3b1hwhnsX5NHCZNzkFbH9_-vIZ@mail.gmail.com>
References: <AANLkTin1OS3LohKBvWyS81BoAk15Y-riCiEdcevSA7ye@mail.gmail.com>
	 <1275929000.3021.56.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTilsCkBiGtfEKkNXYclsRKhfuq4yI_1mrxMa8yJG@mail.gmail.com>
	 <AANLkTik-cwrabXH_bQRPFtTo3C9r30B83jMf4IwJKCms@mail.gmail.com>
	 <20100609211617.3e7e41bd@annuminas.surriel.com>
	 <AANLkTin9UTy3qSWJ8u3b1hwhnsX5NHCZNzkFbH9_-vIZ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Jun 2010 12:21:06 +0100
Message-ID: <1276168866.24535.25.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave,

On Thu, 2010-06-10 at 02:30 +0100, Dave Young wrote:
> On Thu, Jun 10, 2010 at 9:16 AM, Rik van Riel <riel@redhat.com> wrote:
> > On Wed, 9 Jun 2010 17:19:02 +0800
> > Dave Young <hidave.darkstar@gmail.com> wrote:
> >
> >> > Manually bisected mm patches, the memleak caused by following patch:
> >> >
> >> > mm-extend-ksm-refcounts-to-the-anon_vma-root.patch
> >>
> >>
> >> So I guess the refcount break, either drop-without-get or over-drop
> >
> > I'm guessing I did not run the kernel with enough debug options enabled
> > when I tested my patches...
> >
> > Dave & Catalin, thank you for tracking this down.
> >
> > Dave, does the below patch fix your issue?
> 
> Yes, it fixed the issue. Thanks.

Thanks for investigating this issue.

BTW, without my kmemleak nobootmem patch (and CONFIG_NOBOOTMEM enabled),
do you get other leaks (false positives). If my patch fixes the
nobootmem problem, can I add a Tested-by: Dave Young?

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
