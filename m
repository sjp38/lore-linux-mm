Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDE2D6B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:19:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c42so7757722wrc.13
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 02:19:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q39sor7117893edd.39.2017.10.30.02.19.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Oct 2017 02:19:42 -0700 (PDT)
Date: Mon, 30 Oct 2017 12:19:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [pgtable_trans_huge_withdraw] BUG: unable to handle kernel NULL
 pointer dereference at 0000000000000020
Message-ID: <20171030091940.mcljomnaqvrhvwjx@node.shutemov.name>
References: <CA+55aFxSJGeN=2X-uX-on1Uq2Nb8+v1aiMDz5H1+tKW_N5Q+6g@mail.gmail.com>
 <20171029225155.qcum5i75awrt5tzm@wfg-t540p.sh.intel.com>
 <20171029233701.4pjqaesnrjqshmzn@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171029233701.4pjqaesnrjqshmzn@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Geliang Tang <geliangtang@163.com>

On Mon, Oct 30, 2017 at 12:37:01AM +0100, Fengguang Wu wrote:
> CC MM people.
> 
> On Sun, Oct 29, 2017 at 11:51:55PM +0100, Fengguang Wu wrote:
> > Hi Linus,
> > 
> > Up to now we see the below boot error/warnings when testing v4.14-rc6.
> > 
> > They hit the RC release mainly due to various imperfections in 0day's
> > auto bisection. So I manually list them here and CC the likely easy to
> > debug ones to the corresponding maintainers in the followup emails.
> > 
> > boot_successes: 4700
> > boot_failures: 247
> > 
> > BUG:kernel_hang_in_test_stage: 152
> > BUG:kernel_reboot-without-warning_in_test_stage: 10
> > BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/mutex.c: 1
> > BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/rwsem.c: 3
> > BUG:sleeping_function_called_from_invalid_context_at_mm/page_alloc.c: 21
> > BUG:soft_lockup-CPU##stuck_for#s: 1
> > BUG:unable_to_handle_kernel: 13
> 
> Here is the call trace:
> 
> [  956.669197] [  956.670421] stress-ng: fail:  [27945] stress-ng-numa:
> get_mempolicy: errno=22 (Invalid argument)

Can you also share how you run stress-ng? Is it reproducible?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
