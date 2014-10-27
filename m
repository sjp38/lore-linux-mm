Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 76D74900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:38:30 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id q5so7607313wiv.17
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:38:29 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id r2si11796391wia.37.2014.10.27.13.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 13:38:29 -0700 (PDT)
Date: Mon, 27 Oct 2014 21:38:20 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH v9 10/12] x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT,
 PR_MPX_DISABLE_MANAGEMENT
In-Reply-To: <9E0BE1322F2F2246BD820DA9FC397ADE0180ED65@shsmsx102.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.11.1410272137140.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-11-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241436560.5308@nanos> <9E0BE1322F2F2246BD820DA9FC397ADE0180ED65@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>

On Mon, 27 Oct 2014, Ren, Qiaowei wrote:
> On 2014-10-24, Thomas Gleixner wrote:
> > On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> >> +int mpx_enable_management(struct task_struct *tsk) {
> >> +	struct mm_struct *mm = tsk->mm;
> >> +	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
> > 
> > What's the point of initializing bd_base here. I had to look twice to
> > figure out that it gets overwritten by task_get_bounds_dir()
> > 
> 
> I just want to put task_get_bounds_dir() outside mm->mmap_sem holding.

What you want is not interesting at all. What's interesting is what
you do and what you send for review.
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
