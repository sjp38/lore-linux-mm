Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA316B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 08:36:24 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id q5so1092374wiv.7
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 05:36:23 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id l2si1780931wix.39.2014.10.24.05.36.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 05:36:22 -0700 (PDT)
Date: Fri, 24 Oct 2014 14:36:10 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound
 violation information
In-Reply-To: <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com>
Message-ID: <alpine.DEB.2.11.1410241408360.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Sun, 12 Oct 2014, Qiaowei Ren wrote:

> This patch sets bound violation fields of siginfo struct in #BR
> exception handler by decoding the user instruction and constructing
> the faulting pointer.
> 
> This patch does't use the generic decoder, and implements a limited
> special-purpose decoder to decode MPX instructions, simply because the
> generic decoder is very heavyweight not just in terms of performance
> but in terms of interface -- because it has to.

My question still stands why using the existing decoder is an
issue. Performance is a complete non issue in case of a bounds
violation and the interface argument is just silly, really.
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
