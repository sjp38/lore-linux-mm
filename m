Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69C4D6B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:10:41 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j18so21191419ioe.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:10:41 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id 71si2829734iou.49.2017.02.28.09.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 09:10:40 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id w10so2039385iod.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:10:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 28 Feb 2017 09:10:39 -0800
Message-ID: <CA+55aFy3kkfNtdmiGj5+xsJdOuid1V+FFkm_hji0DSuBGqL7jA@mail.gmail.com>
Subject: Re: [PATCH 0/2] fix for direct-I/O to DAX mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Xiong Zhou <xzhou@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sat, Feb 25, 2017 at 9:08 AM, Dan Williams <dan.j.williams@intel.com> wrote:
>
> I'm sending this through the -mm tree for a double-check from memory
> management folks. It has a build success notification from the kbuild
> robot.

I'm just checking that this isn't lost - I didn't get it in the latest
patch-bomb from Andrew.

I'm assuming it's still percolating through your system, Andrew, but
if not, holler.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
