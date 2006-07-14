Subject: Re: [PATCH 1/2] mm: nonresident page tracking
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <215036450607140155w67df26fan5b2342ead686ce8b@mail.gmail.com>
References: <20060711182936.31293.58306.sendpatchset@lappy>
	 <20060711182943.31293.3449.sendpatchset@lappy>
	 <215036450607140155w67df26fan5b2342ead686ce8b@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 14 Jul 2006 16:19:59 +0200
Message-Id: <1152886799.15525.21.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Feng Jin <lkmaillist@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-07-14 at 16:55 +0800, Feng Jin wrote:
> Hi,
> 
> I have applied the patch on 2.6.18-rc1-mm1, and when boot my system,
> kernel panic occured, :(
> I have tyied debug it with kdb, but panic occured at startup, although
> I have add kdb=early, but it still
> could not debug it. 
> attachment is my config file.

>From the fact that the patch doesn't apply cleanly to .18-rc1-mm1, and
that when I fixup the rejects it does boot, I can reach no other
conclusion than that you blotched it somehow.

This patch was against mainline from the day of the post.

As for your suggestion of putting #ifdef CONFIG_MM_NONRESIDENT all over
the place; have you seen how the nonresident.h file declares empty stubs
for the functions?

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
