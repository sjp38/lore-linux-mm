Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 9F38D6B0002
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 12:58:08 -0500 (EST)
Date: Wed, 27 Feb 2013 12:57:57 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1361987877-6x88p62s-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1361984787-yx7rovrg-mutt-n-horiguchi@ah.jp.nec.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130227072517.GA30971@gchen.bj.intel.com>
 <1361984787-yx7rovrg-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/9] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gong.chen@linux.intel.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Wed, Feb 27, 2013 at 12:06:27PM -0500, Naoya Horiguchi wrote:
> On Wed, Feb 27, 2013 at 02:25:17AM -0500, Chen Gong wrote:
> > On Thu, Feb 21, 2013 at 02:41:42PM -0500, Naoya Horiguchi wrote:
> > > Date: Thu, 21 Feb 2013 14:41:42 -0500
> ...
> > > diff --git v3.8.orig/mm/memory-failure.c v3.8/mm/memory-failure.c
> > > index bc126f6..01e4676 100644
> > > --- v3.8.orig/mm/memory-failure.c
> > > +++ v3.8/mm/memory-failure.c
> ...
> > > +		atomic_long_add(1<<compound_trans_order(hpage), &mce_bad_pages);
> > 
> > mce_bad_pages has been substituted by num_poisoned_pages.
> 
> This patchset is based on v3.8 (as show in diff header), where the
> replacing patch "memory-failure: use num_poisoned_pages instead of
> mce_bad_pages" is not merged yet. I'll rebase on v3.8-rc1 in the
> next post.

sorry, s/v3.8-rc1/v3.9-rc1/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
