Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E4C296B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 18:56:03 -0400 (EDT)
Received: by mail-ea0-f181.google.com with SMTP id z10so3588641ead.12
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 15:56:02 -0700 (PDT)
Date: Wed, 27 Mar 2013 23:55:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Message-ID: <20130327225548.GA401@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325150952.GA2154@dhcp22.suse.cz>
 <1364322204-ah777uqs-mutt-n-horiguchi@ah.jp.nec.com>
 <20130327141921.GJ16579@dhcp22.suse.cz>
 <1364419759-a5hijyn0-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364419759-a5hijyn0-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Wed 27-03-13 17:29:19, Naoya Horiguchi wrote:
> On Wed, Mar 27, 2013 at 03:19:21PM +0100, Michal Hocko wrote:
[...]
> > If we made sure that all page on the hugepage_freelists have reference
> > 0 (which is now not the case and it is yet another source of confusion)
> > then the whole loop could be replaced by page_count check.
> 
> I think that free hugepages have refcount 0,

You are right. For some reason I totally missed that we drop
the reference from page allocator (put_page_testzero in
gather_surplus_pages).

Sorry about the stupit question.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
