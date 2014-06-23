Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 455A76B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 16:28:36 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so6331491pab.1
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 13:28:35 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ym1si23520540pac.25.2014.06.23.13.28.35
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 13:28:35 -0700 (PDT)
Message-ID: <53A88DE4.8050107@intel.com>
Date: Mon, 23 Jun 2014 13:28:20 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com> <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu> <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
In-Reply-To: <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 06/23/2014 01:06 PM, Andy Lutomirski wrote:
> Can the new vm_operation "name" be use for this?  The magic "always
> written to core dumps" feature might need to be reconsidered.

One thing I'd like to avoid is an MPX vma getting merged with a non-MPX
vma.  I don't see any code to prevent two VMAs with different
vm_ops->names from getting merged.  That seems like a bit of a design
oversight for ->name.  Right?

Thinking out loud a bit... There are also some more complicated but more
performant cleanup mechanisms that I'd like to go after in the future.
Given a page, we might want to figure out if it is an MPX page or not.
I wonder if we'll ever collide with some other user of vm_ops->name.  It
looks fairly narrowly used at the moment, but would this keep us from
putting these pages on, say, a tmpfs mount?  Doesn't look that way at
the moment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
