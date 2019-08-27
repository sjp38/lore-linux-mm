Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC884C3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:28:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9993C217F5
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:28:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9993C217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10F7D6B0005; Tue, 27 Aug 2019 03:28:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 098A16B0006; Tue, 27 Aug 2019 03:28:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEF776B000A; Tue, 27 Aug 2019 03:28:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC23C6B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 03:28:17 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 757E68243762
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:28:17 +0000 (UTC)
X-FDA: 75867379434.29.run79_828b54435d62d
X-HE-Tag: run79_828b54435d62d
X-Filterd-Recvd-Size: 1538
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:28:16 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4061AE4B;
	Tue, 27 Aug 2019 07:28:15 +0000 (UTC)
Date: Tue, 27 Aug 2019 09:28:13 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>,
	"mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"vbabka@suse.cz" <vbabka@suse.cz>
Subject: Re: poisoned pages do not play well in the buddy allocator
Message-ID: <20190827072808.GA17746@linux>
References: <20190826104144.GA7849@linux>
 <20190827013429.GA5125@hori.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827013429.GA5125@hori.linux.bs1.fc.nec.co.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 01:34:29AM +0000, Naoya Horiguchi wrote:
> > @Naoya: I could give it a try if you are busy.
> 
> Thanks for raising hand. That's really wonderful. I think that the series [1] is not
> merge yet but not rejected yet, so feel free to reuse/update/revamp it.

I will continue pursuing this then :-).

Thanks Naoya!

-- 
Oscar Salvador
SUSE L3

