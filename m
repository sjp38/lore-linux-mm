Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 030236B01AB
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 22:15:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7AC633EE0CB
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 11:15:38 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E36845DE58
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 11:15:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 06CFF45DE64
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 11:15:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 161CD1DB805B
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 11:15:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD0731DB8032
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 11:15:36 +0900 (JST)
Date: Fri, 9 Sep 2011 11:14:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V8 3/4] mm: frontswap: add swap hooks and extend
 try_to_unuse
Message-Id: <20110909111445.4821d326.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <52b5aee3-f424-42ae-830f-d1cf64fa49ef@default>
References: <20110829164929.GA27216@ca-server1.us.oracle.com
 20110907162703.7f8116b9.akpm@linux-foundation.org>
	<52b5aee3-f424-42ae-830f-d1cf64fa49ef@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, 8 Sep 2011 08:50:11 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > From: Andrew Morton [mailto:akpm@linux-foundation.org]
> > Sent: Wednesday, September 07, 2011 5:27 PM
> > To: Dan Magenheimer
> > Subject: Re: [PATCH V8 3/4] mm: frontswap: add swap hooks and extend try_to_unuse
> > 
> > On Mon, 29 Aug 2011 09:49:29 -0700
> > Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
> > 
> > > -static int try_to_unuse(unsigned int type)
> > > +int try_to_unuse(unsigned int type, bool frontswap,
> > 
> > Are patches 2 and 3 in the wrong order?
> 
> No, they've applied in that order and built after each patch
> properly for well over a year.  At a minimum, frontswap.h must
> be created before patch 3of4, though I suppose the introduction
> of frontswap.c could be after patch 3of4... Note that frontswap.c
> (which calls try_to_unuse()) is non-functional (and isn't even built)
> until after patch 4of4 is applied.
> 
> There is enough interdependency between the four parts
> that perhaps it should all be a single commit.  I split
> it up for reviewer's convenience but apparently different
> reviewers use different review processes than I anticipated. :-}
> 

IIRC, I said 'please move this change of line to patch 1'.

Thanks,
-Kame

This was my 1st reply.

> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Subject: [PATCH V7 1/4] mm: frontswap: swap data structure changes
> > 
> > This first patch of four in the frontswap series makes available core
> > swap data structures (swap_lock, swap_list and swap_info) that are
> > needed by frontswap.c but we don't need to expose them to the dozens
> > of files that include swap.h so we create a new swapfile.h just to
> > extern-ify these.
> > 
> > Also add frontswap-related elements to swap_info_struct.  Frontswap_map
> > points to vzalloc'ed one-bit-per-swap-page metadata that indicates
> > whether the swap page is in frontswap or in the device and frontswap_pages
> > counts how many pages are in frontswap.
> > 
> > [v7: rebase to 3.0-rc3]
> > [v7: JBeulich@novell.com: add new swap struct elements only if config'd]
> > [v6: rebase to 3.0-rc1]
> > [v5: no change from v4]
> > [v4: rebase to 2.6.39]
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
> > Acked-by: Jan Beulich <JBeulich@novell.com>
> > Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Nitin Gupta <ngupta@vflare.org>
> > Cc: Matthew Wilcox <matthew@wil.cx>
> > Cc: Chris Mason <chris.mason@oracle.com>
> > Cc: Rik Riel <riel@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> Hmm....could you modify mm/swapfile.c and remove 'static' in the same patch ?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
