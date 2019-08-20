Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08B35C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C75C3214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C75C3214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6541A6B000C; Tue, 20 Aug 2019 10:22:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604846B000D; Tue, 20 Aug 2019 10:22:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 542C16B000E; Tue, 20 Aug 2019 10:22:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id 30E366B000C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:22:02 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B5F928248AC4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:22:01 +0000 (UTC)
X-FDA: 75843020442.28.turn83_860757eaf1353
X-HE-Tag: turn83_860757eaf1353
X-Filterd-Recvd-Size: 3807
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com [47.88.44.36])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:22:00 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=36;SR=0;TI=SMTPD_---0Ta-z0CR_1566310900;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta-z0CR_1566310900)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 22:21:42 +0800
Subject: Re: [PATCH 14/14] mm/lru: fix the comments of lru_lock
To: Matthew Wilcox <willy@infradead.org>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
 Vlastimil Babka <vbabka@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, Jann Horn <jannh@google.com>,
 Logan Gunthorpe <logang@deltatee.com>,
 Souptick Joarder <jrdr.linux@gmail.com>,
 Ralph Campbell <rcampbell@nvidia.com>, "Tobin C. Harding"
 <tobin@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Oscar Salvador <osalvador@suse.de>, Wei Yang <richard.weiyang@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Pavel Tatashin <pasha.tatashin@oracle.com>, Arun KS <arunks@codeaurora.org>,
 "Darrick J. Wong" <darrick.wong@oracle.com>,
 Amir Goldstein <amir73il@gmail.com>, Dave Chinner <dchinner@redhat.com>,
 Josef Bacik <josef@toxicpanda.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Mike Kravetz <mike.kravetz@oracle.com>, Hugh Dickins <hughd@google.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Daniel Jordan <daniel.m.jordan@oracle.com>,
 Yafang Shao <laoar.shao@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <1566294517-86418-15-git-send-email-alex.shi@linux.alibaba.com>
 <20190820140019.GB24642@bombadil.infradead.org>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <bf8be185-e757-cf05-999d-56bfb83f1bc9@linux.alibaba.com>
Date: Tue, 20 Aug 2019 22:21:39 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190820140019.GB24642@bombadil.infradead.org>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=D4=DA 2019/8/20 =CF=C2=CE=E710:00, Matthew Wilcox =D0=B4=B5=C0:
> On Tue, Aug 20, 2019 at 05:48:37PM +0800, Alex Shi wrote:
>> @@ -159,7 +159,7 @@ static inline bool free_area_empty(struct free_are=
a *area, int migratetype)
>>  struct pglist_data;
>> =20
>>  /*
>> - * zone->lock and the zone lru_lock are two of the hottest locks in t=
he kernel.
>> + * zone->lock and the lru_lock are two of the hottest locks in the ke=
rnel.
>>   * So add a wild amount of padding here to ensure that they fall into=
 separate
>>   * cachelines.  There are very few zone structures in the machine, so=
 space
>>   * consumption is not a concern here.
>=20
> But after this patch series, the lru lock is no longer stored in the zo=
ne.
> So this comment makes no sense.

Yes, It's need reconsider here. thanks for opoint out.

>=20
>> @@ -295,7 +295,7 @@ struct zone_reclaim_stat {
>> =20
>>  struct lruvec {
>>  	struct list_head		lists[NR_LRU_LISTS];
>> -	/* move lru_lock to per lruvec for memcg */
>> +	/* perf lruvec lru_lock for memcg */
>=20
> What does the word 'perf' mean here?

sorry for typo, could be s/perf/per/ here.

Thanks
Alex

=20

