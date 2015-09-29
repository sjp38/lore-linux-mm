Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3E62B6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 04:44:27 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so139586299wic.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 01:44:26 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id h6si27886931wib.97.2015.09.29.01.44.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 01:44:26 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so138326127wic.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 01:44:26 -0700 (PDT)
Date: Tue, 29 Sep 2015 10:44:22 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 06/11] x86/virt/guest/xen: Remove use of pgd_list from
 the Xen guest code
Message-ID: <20150929084422.GB332@gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-7-git-send-email-mingo@kernel.org>
 <CA+55aFw5BLBTFWQpcOGYv4ALAM02aywTk1vz5ng=wqPnNH3qKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw5BLBTFWQpcOGYv4ALAM02aywTk1vz5ng=wqPnNH3qKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
> > xen_mm_pin_all()/unpin_all() are used to implement full guest instance
> > suspend/restore. It's a stop-all method that needs to iterate through
> > all allocated pgds in the system to fix them up for Xen's use.
> 
> And _this_ is why I'd reall ylike that "for_each_mm()" helper.
> 
> Yeah, yeah, maybe it would require syntax like
> 
>     for_each_mm (tsk, mm) {
>         ...
>     } end_for_each_mm(mm);
> 
> to do variable allocation things or cleanups (ie "end_for_each_mm()" might drop 
> the task lock etc), but wouldn't that still be better than this complex 
> boilerplate thing?

Yeah, agreed absolutely.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
