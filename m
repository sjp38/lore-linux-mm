Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 974166B009E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 18:47:07 -0400 (EDT)
Date: Wed, 11 Sep 2013 00:47:04 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 5/9] mbind: add hugepage migration code to mbind()
Message-ID: <20130910224704.GD18242@two.firstfloor.org>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130910144109.GR22421@suse.de>
 <1378850009-y4wd5ph0-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378850009-y4wd5ph0-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

> > It makes me wonder how actually useful generic hugetlbfs page migration
> > will be in practice. Are there really usecases where the system
> > administrator is willing to create unused hugepage pools on each node
> > just to enable migration?
> 
> Maybe most users don't want it.

I'm sure some power users will be willing to do that.
Of course for a lot of others THP is enough.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
