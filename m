Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D2AC86B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 12:23:04 -0400 (EDT)
Subject: Re: [PATCH 3/6] Mempolicy: rename policy_types and cleanup
 initialization
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.1003220942430.15360@router.home>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
	 <20100319185952.21430.8872.sendpatchset@localhost.localdomain>
	 <alpine.DEB.2.00.1003220942430.15360@router.home>
Content-Type: text/plain
Date: Mon, 22 Mar 2010 12:22:59 -0400
Message-Id: <1269274979.23955.25.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-22 at 09:43 -0500, Christoph Lameter wrote:
> On Fri, 19 Mar 2010, Lee Schermerhorn wrote:
> 
> > Rename 'policy_types[]' to 'policy_modes[]' to better match the
> > array contents.
> 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Small nitpick: MPOL_MAX should be called MPOL_NR to follow vmstat.h and
> mmzones.h's way of naming the n+1st element.

The 'MPOL_MAX' has been there since David R [wasn't it?] created the
enum.  The current name shows up in user space numaif.h from the numactl
package [2.0.3] as a #define of MPOL_MAX to MPOL_INTERLEAVE .  I suppose
we could #define it to MPOL_NR to avoid the possibility of application
breakage if the enum ever makes it to the user space header.   I checked
numactl sources and the only use of MPOL_MAX in the package is one of
the test programs.  Don't know about end user apps out there in the
wild, tho'.

David:  what do you think?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
