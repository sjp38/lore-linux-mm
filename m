Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF3166B025E
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 01:17:16 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n126so2870465wma.7
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 22:17:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9sor1393449wmb.4.2017.12.06.22.17.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 22:17:15 -0800 (PST)
Date: Thu, 7 Dec 2017 07:17:12 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 2/4] x86/boot/compressed/64: Rename pagetable.c to
 kaslr_64.c
Message-ID: <20171207061712.vtk7tbbsk55vesea@gmail.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
 <20171205135942.24634-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205135942.24634-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> The name of the file -- pagetable.c -- is misleading: it only contains
> helpers used for KASLR in 64-bin mode.

s/64-bin mode
 /64-bit mode

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
