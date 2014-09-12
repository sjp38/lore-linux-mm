Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 11F216B0039
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:52:48 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id w62so1147352wes.12
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 10:52:48 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id iu6si4098270wic.41.2014.09.12.10.52.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 10:52:47 -0700 (PDT)
Date: Fri, 12 Sep 2014 19:52:37 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
In-Reply-To: <541223B1.5040705@zytor.com>
Message-ID: <alpine.DEB.2.10.1409121949460.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120015030.4178@nanos> <5412230A.6090805@intel.com> <541223B1.5040705@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Qiaowei Ren <qiaowei.ren@intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Sep 2014, H. Peter Anvin wrote:

> On 09/11/2014 03:32 PM, Dave Hansen wrote:
> > On 09/11/2014 03:18 PM, Thomas Gleixner wrote:
> >> On Thu, 11 Sep 2014, Qiaowei Ren wrote:
> >>> This patch sets bound violation fields of siginfo struct in #BR
> >>> exception handler by decoding the user instruction and constructing
> >>> the faulting pointer.
> >>>
> >>> This patch does't use the generic decoder, and implements a limited
> >>> special-purpose decoder to decode MPX instructions, simply because the
> >>> generic decoder is very heavyweight not just in terms of performance
> >>> but in terms of interface -- because it has to.
> >>
> >> And why is that an argument to add another special purpose decoder?
> > 
> > Peter asked for it to be done this way specifically:
> > 
> > 	https://lkml.org/lkml/2014/6/19/411
> > 
> 
> Specifically because marshaling the data in and out of the generic
> decoder was more complex than a special-purpose decoder.

Well, I did not see the trainwreck which tried to use the generic
decoder, but as I explained in the other mail, there is no reason not
to use it and I can't see any complexity in retrieving the data beyond
calling insn_get_length(insn);

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
