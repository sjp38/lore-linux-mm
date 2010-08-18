Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F03D16B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 03:46:31 -0400 (EDT)
Date: Wed, 18 Aug 2010 09:46:23 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/9] Hugepage migration (v2)
Message-ID: <20100818074623.GA6866@basil.fritz.box>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008130744550.27542@router.home>
 <20100816091935.GB3388@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008160707420.11420@router.home>
 <20100817023719.GC12736@spritzera.linux.bs1.fc.nec.co.jp>
 <20100817081817.GA28969@spritzera.linux.bs1.fc.nec.co.jp>
 <20100817094007.GA18161@basil.fritz.box>
 <20100818073234.GA28961@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818073234.GA28961@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 04:32:34PM +0900, Naoya Horiguchi wrote:
> On Tue, Aug 17, 2010 at 11:40:08AM +0200, Andi Kleen wrote:
> > > When get_user_pages_fast() is called before try_to_unmap(),
> > > direct I/O code increments refcount on the target page.
> > > Because this refcount is not associated to the mapping,
> > > migration code will find remaining refcounts after try_to_unmap()
> > > unmaps all mappings. Then refcount check decides migration to fail,
> > > so direct I/O is continued safely.
> > 
> > This would imply that direct IO can make migration fail arbitarily.
> > Also not good. Should we add some retries, at least for the soft offline
> > case?
> 
> Soft offline is kicked from userspace, so the retry logic can be implemented
> in userspace. However, currently we can't distinguish migration failure from

I don't think user space is the right place for retry logic.
It doesn't really have enough information to make a good decision when
to reply.

Also I would consider requiring user space to work around kernel problems like
that bad design.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
