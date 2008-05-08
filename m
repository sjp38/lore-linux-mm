Date: Thu, 8 May 2008 16:34:53 +0200
From: Hans Rosenfeld <hans.rosenfeld@amd.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
Message-ID: <20080508143453.GE12654@escobedo.amd.com>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com> <20080506124946.GA2146@elte.hu> <Pine.LNX.4.64.0805061435510.32567@blonde.site> <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org> <Pine.LNX.4.64.0805062043580.11647@blonde.site> <20080506202201.GB12654@escobedo.amd.com> <1210106579.4747.51.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1210106579.4747.51.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 01:42:59PM -0700, Dave Hansen wrote:
> Could you post the code you're using to do this?  I have to wonder if
> you're leaving a fd open somewhere.  Even if you rm the hugepage file,
> it'll stay allocated if you have a fd open, or if *someone* is still
> mapping it. 

A stripped-down program exposing the leak is attached. It doesn't fork
or do any other fancy stuff, so I don't see a way it could leave any fd
open.

While trying to reproduce this, I noticed that the huge page wouldn't
leak when I just mmapped it and exited without explicitly unmapping, as
I described before. The huge page is leaked only when the
/proc/self/pagemap entry for the huge page is read. The kernel I tested
with was 2.6.26-rc1-00179-g3de2403.

> Can you umount your hugetlbfs?

Yes, but the pages remain lost.

Hans


-- 
%SYSTEM-F-ANARCHISM, The operating system has been overthrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
