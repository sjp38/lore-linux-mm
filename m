Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A17AF6B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 17:09:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x17so32277571pgi.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 14:09:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h6si2854359pln.175.2017.02.28.14.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 14:09:55 -0800 (PST)
Date: Tue, 28 Feb 2017 14:09:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] fix for direct-I/O to DAX mappings
Message-Id: <20170228140954.09b9a85dd626a632d3beeb07@linux-foundation.org>
In-Reply-To: <CA+55aFy3kkfNtdmiGj5+xsJdOuid1V+FFkm_hji0DSuBGqL7jA@mail.gmail.com>
References: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
	<CA+55aFy3kkfNtdmiGj5+xsJdOuid1V+FFkm_hji0DSuBGqL7jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, the arch/x86 maintainers <x86@kernel.org>, Xiong Zhou <xzhou@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, 28 Feb 2017 09:10:39 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sat, Feb 25, 2017 at 9:08 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > I'm sending this through the -mm tree for a double-check from memory
> > management folks. It has a build success notification from the kbuild
> > robot.
> 
> I'm just checking that this isn't lost - I didn't get it in the latest
> patch-bomb from Andrew.
> 
> I'm assuming it's still percolating through your system, Andrew, but
> if not, holler.
> 

Yup, I've got them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
