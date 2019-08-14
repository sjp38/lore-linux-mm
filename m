Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB4B7C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 09:19:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91D0920843
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 09:19:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91D0920843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E86CA6B0005; Wed, 14 Aug 2019 05:19:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E37AC6B0006; Wed, 14 Aug 2019 05:19:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4EA36B0007; Wed, 14 Aug 2019 05:19:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id B34966B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 05:19:40 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 494CCBEEC
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:19:40 +0000 (UTC)
X-FDA: 75820485720.16.laugh80_374ba691b0719
X-HE-Tag: laugh80_374ba691b0719
X-Filterd-Recvd-Size: 1793
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:19:39 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3965DADAA;
	Wed, 14 Aug 2019 09:19:38 +0000 (UTC)
Subject: Re: [PATCH 3/3] mm/mmap.c: extract __vma_unlink_list as counter part
 for __vma_link_list
To: Wei Yang <richardw.yang@linux.intel.com>,
 Christoph Hellwig <hch@infradead.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net,
 osalvador@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190814021755.1977-1-richardw.yang@linux.intel.com>
 <20190814021755.1977-3-richardw.yang@linux.intel.com>
 <20190814051611.GA1958@infradead.org> <20190814065703.GA6433@richard>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2c5cdffd-f405-23b8-98f5-37b95ca9b027@suse.cz>
Date: Wed, 14 Aug 2019 11:19:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190814065703.GA6433@richard>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/14/19 8:57 AM, Wei Yang wrote:
> On Tue, Aug 13, 2019 at 10:16:11PM -0700, Christoph Hellwig wrote:
>>Btw, is there any good reason we don't use a list_head for vma linkage?
> 
> Not sure, maybe there is some historical reason?

Seems it was single-linked until 2010 commit 297c5eee3724 ("mm: make the vma
list be doubly linked") and I guess it was just simpler to add the vm_prev link.

Conversion to list_head might be an interesting project for some "advanced
beginner" in the kernel :)


