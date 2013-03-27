Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 89A786B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 17:58:42 -0400 (EDT)
Date: Wed, 27 Mar 2013 17:58:28 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364421508-fjm1vfw0-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1364419759-a5hijyn0-mutt-n-horiguchi@ah.jp.nec.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325150952.GA2154@dhcp22.suse.cz>
 <1364322204-ah777uqs-mutt-n-horiguchi@ah.jp.nec.com>
 <20130327141921.GJ16579@dhcp22.suse.cz>
 <1364419759-a5hijyn0-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 05:29:19PM -0400, Naoya Horiguchi wrote:
...
> > If we made sure that all page on the hugepage_freelists have reference
> > 0 (which is now not the case and it is yet another source of confusion)
> > then the whole loop could be replaced by page_count check.
> 
> I think that free hugepages have refcount 0, but hwpoisoned hugepages
> have also refcount 0. But hwpoison can happen only on limited hardware
> and we consider them as exceptional, so replacing page_count check and
> checking PG_hwpoisoned flag looks more reasonable to me.

Sorry, my mistake. Hwpoisoned hugepages have refcount 1, so there's
no problem on using page_count check.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
