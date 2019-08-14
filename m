Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14491C32750
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:20:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5A2020842
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:20:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5A2020842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 932596B0005; Tue, 13 Aug 2019 22:20:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9118D6B0006; Tue, 13 Aug 2019 22:20:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 846CF6B0007; Tue, 13 Aug 2019 22:20:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 617FD6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 22:20:18 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C426D4850
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:20:17 +0000 (UTC)
X-FDA: 75819428874.17.bean43_1f98d3d4c953e
X-HE-Tag: bean43_1f98d3d4c953e
X-Filterd-Recvd-Size: 2017
Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:20:16 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 19:20:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="181365818"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga006.jf.intel.com with ESMTP; 13 Aug 2019 19:20:13 -0700
Date: Wed, 14 Aug 2019 10:19:50 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
	mgorman@techsingularity.net, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: rb_parent is not necessary in __vma_link_list
Message-ID: <20190814021950.GA2025@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190813032656.16625-1-richardw.yang@linux.intel.com>
 <20190813033958.GB5307@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813033958.GB5307@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 08:39:58PM -0700, Matthew Wilcox wrote:
>On Tue, Aug 13, 2019 at 11:26:56AM +0800, Wei Yang wrote:
>> Now we use rb_parent to get next, while this is not necessary.
>> 
>> When prev is NULL, this means vma should be the first element in the
>> list. Then next should be current first one (mm->mmap), no matter
>> whether we have parent or not.
>> 
>> After removing it, the code shows the beauty of symmetry.
>
>Uhh ... did you test this?
>

I have enabled DEBUG_VM_RB, system looks good with this.

-- 
Wei Yang
Help you, Help me

