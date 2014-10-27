Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 648D4900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:37:08 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id q5so7110904wiv.0
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:37:07 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id xu9si6025768wjb.135.2014.10.27.13.37.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 13:37:06 -0700 (PDT)
Date: Mon, 27 Oct 2014 21:36:53 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound
 violation information
In-Reply-To: <9E0BE1322F2F2246BD820DA9FC397ADE0180ED16@shsmsx102.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.11.1410272135420.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241408360.5308@nanos> <9E0BE1322F2F2246BD820DA9FC397ADE0180ED16@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>

On Mon, 27 Oct 2014, Ren, Qiaowei wrote:
> On 2014-10-24, Thomas Gleixner wrote:
> > On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> > 
> >> This patch sets bound violation fields of siginfo struct in #BR
> >> exception handler by decoding the user instruction and constructing
> >> the faulting pointer.
> >> 
> >> This patch does't use the generic decoder, and implements a limited
> >> special-purpose decoder to decode MPX instructions, simply because
> >> the generic decoder is very heavyweight not just in terms of
> >> performance but in terms of interface -- because it has to.
> > 
> > My question still stands why using the existing decoder is an issue.
> > Performance is a complete non issue in case of a bounds violation and
> > the interface argument is just silly, really.
> > 
> 
> As hpa said, we only need to decode several mpx instructions
> including BNDCL/BNDCU, and general decoder looks like a little
> heavy. Peter, what do you think about it?

You're repeating yourself. Care to read the discussion about this from
the last round of review again?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
