Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 26A986B0068
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 15:36:04 -0400 (EDT)
Date: Wed, 22 Aug 2012 12:35:32 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 2/5] mempolicy: Remove mempolicy sharing
Message-ID: <20120822193532.GB12707@tassilo.jf.intel.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
 <1345480594-27032-3-git-send-email-mgorman@suse.de>
 <20120822120314.9fc30d47.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120822120314.9fc30d47.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Aug 22, 2012 at 12:03:14PM -0700, Andrew Morton wrote:
> On Mon, 20 Aug 2012 17:36:31 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > Dave Jones' system call fuzz testing tool "trinity" triggered the following
> > bug error with slab debugging enabled
> > 
> > ...
> >
> > Cc: <stable@vger.kernel.org>
> 
> The patch dosn't apply to 3.5 at all well.  I don't see much point in
> retaining the stable tag so I think I'll remove it, and suggest that
> you prepare a fresh patch for Greg and explain the situation?

Everything applies fine if you redo the revert manually.

BTW we tested it now and the new patchkit indeed fixes the database.
Please queue for 3.6 and 3.5 stable.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
