Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09A56C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 06:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBB31208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 06:57:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBB31208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 701E96B0005; Wed, 14 Aug 2019 02:57:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B2C76B0006; Wed, 14 Aug 2019 02:57:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C9576B0007; Wed, 14 Aug 2019 02:57:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6356B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:57:30 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E8112181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 06:57:29 +0000 (UTC)
X-FDA: 75820127418.29.spot60_7b99cbc9a3d00
X-HE-Tag: spot60_7b99cbc9a3d00
X-Filterd-Recvd-Size: 1755
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 06:57:29 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 23:57:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,384,1559545200"; 
   d="scan'208";a="188028665"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga002.jf.intel.com with ESMTP; 13 Aug 2019 23:57:26 -0700
Date: Wed, 14 Aug 2019 14:57:03 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
	mgorman@techsingularity.net, vbabka@suse.cz, osalvador@suse.de,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] mm/mmap.c: extract __vma_unlink_list as counter part
 for __vma_link_list
Message-ID: <20190814065703.GA6433@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190814021755.1977-1-richardw.yang@linux.intel.com>
 <20190814021755.1977-3-richardw.yang@linux.intel.com>
 <20190814051611.GA1958@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814051611.GA1958@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 10:16:11PM -0700, Christoph Hellwig wrote:
>Btw, is there any good reason we don't use a list_head for vma linkage?

Not sure, maybe there is some historical reason?

-- 
Wei Yang
Help you, Help me

