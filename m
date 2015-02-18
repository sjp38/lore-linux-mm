Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id BB8366B00B0
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 17:14:41 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id wo20so7797144obc.7
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 14:14:41 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id dw8si4403826obb.9.2015.02.18.14.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 14:14:41 -0800 (PST)
Message-ID: <1424297657.17007.37.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 6/7] x86, mm: Support huge I/O mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 18 Feb 2015 15:14:17 -0700
In-Reply-To: <20150218215722.GA27863@gmail.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
	 <1423521935-17454-7-git-send-email-toshi.kani@hp.com>
	 <20150218204414.GA20943@gmail.com>
	 <1424294020.17007.21.camel@misato.fc.hp.com>
	 <20150218211555.GA22696@gmail.com>
	 <1424295209.17007.34.camel@misato.fc.hp.com>
	 <20150218215722.GA27863@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Wed, 2015-02-18 at 22:57 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > On Wed, 2015-02-18 at 22:15 +0100, Ingo Molnar wrote:
> > > * Toshi Kani <toshi.kani@hp.com> wrote:
> > > 
> > > > On Wed, 2015-02-18 at 21:44 +0100, Ingo Molnar wrote:
 :
> > 
> > > > [...]  That said, since the patchset also added a new 
> > > > nohugeiomap boot option for the same purpose, I agree 
> > > > that this Kconfig option can be removed.  So, I will 
> > > > remove it in the next version.
> > > > 
> > > > An example of such case is with multiple MTRRs described 
> > > > in patch 0/7.
> > > 
> > > So the multi-MTRR case should probably be detected and 
> > > handled safely?
> > 
> > I considered two options to safely handle this case, i.e. 
> > option A) and B) described in the link below.
> >
> >   https://lkml.org/lkml/2015/2/5/638
> > 
> > I thought about how much complication we should put into 
> > the code for an imaginable platform with a combination of 
> > new NVM (or large I/O range) and legacy MTRRs with 
> > multi-types & contiguous ranges.  My thinking is that we 
> > should go with option C) for simplicity, and implement A) 
> > or B) later if we find it necessary.
> 
> Well, why not option D):
> 
>    D) detect unaligned requests and reject them
> 

That sounds like a good idea!  I will work on it. 

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
