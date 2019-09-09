Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A05CC49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33DF22196E
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:00:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33DF22196E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA93B6B0005; Mon,  9 Sep 2019 11:00:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A58356B0006; Mon,  9 Sep 2019 11:00:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96E416B0007; Mon,  9 Sep 2019 11:00:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id 736C66B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:00:00 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 25F1C909B
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:00:00 +0000 (UTC)
X-FDA: 75915692160.29.bell12_1d124994c5922
X-HE-Tag: bell12_1d124994c5922
X-Filterd-Recvd-Size: 1545
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:59:59 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92800AC35;
	Mon,  9 Sep 2019 14:59:58 +0000 (UTC)
Subject: Re: [PATCH 2/5] mm, slab_common: Remove unused kmalloc_cache_name()
To: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190903160430.1368-1-lpf.vector@gmail.com>
 <20190903160430.1368-3-lpf.vector@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <80fe024b-006e-b38e-1548-70441d917b41@suse.cz>
Date: Mon, 9 Sep 2019 16:59:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190903160430.1368-3-lpf.vector@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/3/19 6:04 PM, Pengfei Li wrote:
> Since the name of kmalloc can be obtained from kmalloc_info[],
> remove the kmalloc_cache_name() that is no longer used.

That could simply be part of patch 1/5 really.

> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>

Ack

> ---
>   mm/slab_common.c | 15 ---------------
>   1 file changed, 15 deletions(-)

