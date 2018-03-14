Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 442796B0007
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 15:56:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j4so2521851wrg.11
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 12:56:46 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k89si610617edc.108.2018.03.14.12.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 12:56:44 -0700 (PDT)
Date: Wed, 14 Mar 2018 20:56:41 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] x86/mm: remove pointless checks in vmalloc_fault
In-Reply-To: <1521056327.2693.138.camel@hpe.com>
Message-ID: <alpine.DEB.2.21.1803142054390.1946@nanos.tec.linutronix.de>
References: <20180313170347.3829-1-toshi.kani@hpe.com>  <20180313170347.3829-3-toshi.kani@hpe.com>  <alpine.DEB.2.21.1803142024540.1946@nanos.tec.linutronix.de> <1521056327.2693.138.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "gratian.crisan@ni.com" <gratian.crisan@ni.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>

On Wed, 14 Mar 2018, Kani, Toshi wrote:
> On Wed, 2018-03-14 at 20:27 +0100, Thomas Gleixner wrote:
> > On Tue, 13 Mar 2018, Toshi Kani wrote:
> > 
> > > vmalloc_fault() sets user's pgd or p4d from the kernel page table.
> > > Once it's set, all tables underneath are identical. There is no point
> > > of following the same page table with two separate pointers and makes
> > > sure they see the same with BUG().
> > > 
> > > Remove the pointless checks in vmalloc_fault(). Also rename the kernel
> > > pgd/p4d pointers to pgd_k/p4d_k so that their names are consistent in
> > > the file.
> > 
> > I have no idea to which branch this might apply. The first patch applies
> > cleanly on linus head, but this one fails in hunk #2 on everything I
> > tried. Can you please check?
> 
> Sorry for the trouble. The patches are based on linus head. I just tried
> and they applied clean to me... 

Hmm. Looks like I tried on the wrong branch. Nevertheless, 1/2 is queued in
urgent, but 2/2 will go through tip/x86/mm which already has changes in
that area causing the patch to fail. I just merged x86/urgent into x86/mm
and pushed it out. Can you please rebase 2/2 on top of that bracnh and
resend ?

Thanks,

	tglx
