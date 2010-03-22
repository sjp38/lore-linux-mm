Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CFBFF6B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 12:11:55 -0400 (EDT)
Subject: Re: [PATCH 1/6] Mempolicy: Don't call mpol_set_nodemask() when
 no_context
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.1003220939410.15360@router.home>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
	 <20100319185940.21430.38739.sendpatchset@localhost.localdomain>
	 <alpine.DEB.2.00.1003220939410.15360@router.home>
Content-Type: text/plain
Date: Mon, 22 Mar 2010 12:11:49 -0400
Message-Id: <1269274309.23955.14.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-22 at 09:40 -0500, Christoph Lameter wrote:
> Just use i instead of mode? Local variables typically have short names.
> "mode" sounds like a parameter. 

That was probably my thinking when I used 'i' for the loop variable back
when I replaced the 'if-elseif' skip chain with the for loop to reuse
the [then] "policy_types[]" array from mpol_to_str().  But, I then went
and assigned it to the more meaningful 'mode' to carry around the rest
of function.  Looking at it this time around, seemed like I didn't need
2 vars, and outside of the loop, I thought 'mode' would be
better--reinforcing the nomenclature.

> But its just
>  style so ignore my comments
> if you want.
> 

Aw, would I do that?  But, let's wait to see if anyone else weighs in.
I'm not wedded to either one, except for the rationale, such as it is,
mentioned above.

Thanks for the review.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
