Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id E68BE6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 16:46:37 -0400 (EDT)
Date: Wed, 31 Jul 2013 16:46:21 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375303581-l14hjkth-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130731050824.GJ2548@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-12-git-send-email-iamjoonsoo.kim@lge.com>
 <1375123170-v27s5zvu-mutt-n-horiguchi@ah.jp.nec.com>
 <20130731050824.GJ2548@lge.com>
Subject: Re: [PATCH 11/18] mm, hugetlb: move down outside_reserve check
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Wed, Jul 31, 2013 at 02:08:24PM +0900, Joonsoo Kim wrote:
> On Mon, Jul 29, 2013 at 02:39:30PM -0400, Naoya Horiguchi wrote:
> > On Mon, Jul 29, 2013 at 02:32:02PM +0900, Joonsoo Kim wrote:
> > > Just move down outsider_reserve check.
> > > This makes code more readable.
> > > 
> > > There is no functional change.
> > 
> > Why don't you do this in 10/18?
> 
> Just help to review :)
> Step-by-step approach may help to review, so I decide to be separate it.
> If you don't want it, I will merge it in next spin.

OK, it's up to you actually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
