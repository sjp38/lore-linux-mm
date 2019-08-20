Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F483C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:40:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 136A4233FE
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:40:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LqgG+2Wd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 136A4233FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A438E6B026E; Tue, 20 Aug 2019 09:40:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F4B46B026F; Tue, 20 Aug 2019 09:40:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90A296B0270; Tue, 20 Aug 2019 09:40:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id 707096B026E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:40:44 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 19472180AD80B
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:40:44 +0000 (UTC)
X-FDA: 75842916408.09.ants41_4093435886b3c
X-HE-Tag: ants41_4093435886b3c
X-Filterd-Recvd-Size: 3684
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:40:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=B8LOvtinbA79S6NGUvPmiLsFutes9sDZnF3rriD/5Mw=; b=LqgG+2Wdt6591p4WO0+ZJbqG6
	JVwTerajJO10FChITzDm05wP2VLtJnRRALEsBN7lsG55BOjyn6LJqArhyPi3bXAVRiBtxrTIhVrGR
	dmyT7Q0/4ozU+NDkCoQ/0z2ri/SOjl8JXuwudo7C/gjOUeWgoXYQh6VKjtldhzkcQ1usxbl+YUCJ8
	eYICpPUrQ3PQaIjpM7+lIJBtpr13OYextxKSxKz6NELTmP6n+QIOUH/DRp5wUH9Y4G1TJWigSzkWx
	uLj+hzSg/dfvmLL9uPbxkKLxvFoeoFGigZRqWKfM95/1lnk9qu4wSzinaCZd34957WhaXkdSxjpeI
	Z98gbhvhA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i04NE-0002hI-Qz; Tue, 20 Aug 2019 13:40:32 +0000
Date: Tue, 20 Aug 2019 06:40:32 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Alex Shi <alex.shi@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richard.weiyang@gmail.com>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Hugh Dickins <hughd@google.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	David Rientjes <rientjes@google.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	swkhack <swkhack@gmail.com>,
	"Potyra, Stefan" <Stefan.Potyra@elektrobit.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Colin Ian King <colin.king@canonical.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Peng Fan <peng.fan@nxp.com>, Ira Weiny <ira.weiny@intel.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Yafang Shao <laoar.shao@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>
Subject: Re: [PATCH 01/14] mm/lru: move pgdat lru_lock into lruvec
Message-ID: <20190820134032.GA24642@bombadil.infradead.org>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <1566294517-86418-2-git-send-email-alex.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566294517-86418-2-git-send-email-alex.shi@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:48:24PM +0800, Alex Shi wrote:
> +++ b/include/linux/mmzone.h
> @@ -295,6 +295,9 @@ struct zone_reclaim_stat {
>  
>  struct lruvec {
>  	struct list_head		lists[NR_LRU_LISTS];
> +	/* move lru_lock to per lruvec for memcg */
> +	spinlock_t			lru_lock;

This comment makes no sense outside the context of this patch.

