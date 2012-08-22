Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id D8C346B0068
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 15:39:54 -0400 (EDT)
Date: Wed, 22 Aug 2012 20:33:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/5] mempolicy: Remove mempolicy sharing
Message-ID: <20120822193357.GE15058@suse.de>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
 <1345480594-27032-3-git-send-email-mgorman@suse.de>
 <20120822120314.9fc30d47.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120822120314.9fc30d47.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

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
> 

Sure. I'll do the backport at the time they get merged to mainline and
jump through the hoops. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
