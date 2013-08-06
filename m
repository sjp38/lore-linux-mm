Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 2874B6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 00:30:44 -0400 (EDT)
Date: Tue, 06 Aug 2013 00:30:03 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375763403-g7t50glu-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <87haf3oabh.fsf@linux.vnet.ibm.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374728103-17468-9-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87k3k7q4ox.fsf@linux.vnet.ibm.com>
 <1375302249-scfvftrh-mutt-n-horiguchi@ah.jp.nec.com>
 <87vc3qvtmc.fsf@linux.vnet.ibm.com>
 <1375411396-bw4cbhso-mutt-n-horiguchi@ah.jp.nec.com>
 <87haf3oabh.fsf@linux.vnet.ibm.com>
Subject: Re: [PATCH 8/8] prepare to remove
 /proc/sys/vm/hugepages_treat_as_movable
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Aug 06, 2013 at 07:22:02AM +0530, Aneesh Kumar K.V wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> >> 
> >> Considering that we have architectures that won't support migrating
> >> explicit hugepages with this patch series, is it ok to use
> >> GFP_HIGHUSER_MOVABLE for hugepage allocation ?
> >
> > Originally this parameter was introduced to make hugepage pool on ZONE_MOVABLE.
> > The benefit is that we can extend the hugepage pool more easily,
> > because external fragmentation less likely happens than other zone type
> > by rearranging fragmented pages with page migration/reclaim.
> >
> > So I think using ZONE_MOVABLE for hugepage allocation by default makes sense
> > even on the architectures which don't support hugepage migration.
> 
> But allocating hugepages from ZONE_MOVABLE means we have pages in that
> zone which we can't migrate. Doesn't that impact other features like
> hotplug ?

Memory blocks occupied by hugepages are not removable before this patchset,
whether they are from ZONE_MOVABLE or not, and the hugepage users accepted
it for now. So I think this change doesn't make things worse than now. 

It can be more preferable to switch on/off __GFP_MOVABLE flag depending on
archs without using the tunable parameter. I'm ok for this direction, but
I want to do it as a separate work.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
