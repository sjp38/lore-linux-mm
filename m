Date: Thu, 8 May 2003 08:54:40 +0200
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030508065440.GA1890@hh.idb.hist.no>
References: <3EB8E4CC.8010409@aitel.hist.no> <20030507.025626.10317747.davem@redhat.com> <20030507144100.GD8978@holomorphy.com> <20030507.064010.42794250.davem@redhat.com> <20030507215430.GA1109@hh.idb.hist.no> <20030508013854.GW8931@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030508013854.GW8931@holomorphy.com>
From: Helge Hafting <helgehaf@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Helge Hafting <helgehaf@aitel.hist.no>, "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2003 at 06:38:54PM -0700, William Lee Irwin III wrote:
[...] 
> Can you try one kernel with the netfilter cset backed out, and another
> with the re-slabification patch backed out? (But not with both backed
> out simultaneously).

I'm compiling without reslabify now.
I got 
patching file arch/i386/mm/pageattr.c
Hunk #1 succeeded at 67 (offset 9 lines).
when backing it out - is this the effect of
some other patch touching the same file or could
my source be wrong somehow?

Which patch is the netfilter cset?  None of
the patches in mm2 looked obvious to me.  Or
is it part of the linus patch? Note that mm1
works for me, so anything found there too
isn't as likely to be the problem.

Helge Hafting
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
