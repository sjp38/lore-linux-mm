Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9FBD86B01C7
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 06:06:23 -0400 (EDT)
Subject: Re: [PATCH -mm] only drop root anon_vma if not self
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTiktcGrj-tcMspzR3sXplKk-PFB7M4q7rb-WiwYP@mail.gmail.com>
References: <AANLkTiktcGrj-tcMspzR3sXplKk-PFB7M4q7rb-WiwYP@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Jun 2010 11:06:12 +0100
Message-ID: <1276250772.12258.57.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-06-11 at 10:48 +0100, Dave Young wrote:
> I got an oops when shutdown kvm guest with rik's patch applied, but
> without your bootmem patch, is it kmemleak problem?

It could be, though I've never got it before.

Can you run this on your vmlinux file?

addr2line -i -f -e vmlinux c10c5c88

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
