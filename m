Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B519D6B0073
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:19:02 -0400 (EDT)
Date: Wed, 28 Oct 2009 18:18:55 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028171855.GU7744@basil.fritz.box>
References: <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random> <20091028042805.GJ7744@basil.fritz.box> <20091028120050.GD9640@random.random> <20091028141803.GQ7744@basil.fritz.box> <20091028154827.GF9640@random.random> <20091028160352.GS7744@basil.fritz.box> <20091028162206.GG9640@random.random> <20091028163458.GT7744@basil.fritz.box> <1256749015.5613.31.camel@aglitke>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1256749015.5613.31.camel@aglitke>
Sender: owner-linux-mm@kvack.org
To: Adam Litke <agl@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 11:56:55AM -0500, Adam Litke wrote:
> > I think you need some user visible interfaces to cleanly handle existing
> > reservations on a process base at least, otherwise you'll completely break 
> > their semantics.
> 
> But we already handle explicit hugepages (with page pools and strict
> reservations) via hugetlbfs and libhugetlbfs.  It seems you're just
> making an argument for keeping these around (which I certainly agree
> with).

That would require not supporting reservations through the transparent
mechanism. That wouldn't be very nice semantics, because you end up
with "glass jaw" performance always in the transparent case.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
