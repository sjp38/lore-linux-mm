Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F2E4C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 208C52070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:14:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 208C52070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A9406B0563; Mon, 26 Aug 2019 07:14:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 732786B0565; Mon, 26 Aug 2019 07:14:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6217A6B0566; Mon, 26 Aug 2019 07:14:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0225.hostedemail.com [216.40.44.225])
	by kanga.kvack.org (Postfix) with ESMTP id 45C706B0563
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:14:18 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 01C9F824CA3E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:14:18 +0000 (UTC)
X-FDA: 75864320196.17.floor50_86597f684f4d
X-HE-Tag: floor50_86597f684f4d
X-Filterd-Recvd-Size: 1829
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:14:17 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 19094ABB2;
	Mon, 26 Aug 2019 11:14:16 +0000 (UTC)
Date: Mon, 26 Aug 2019 13:14:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, vbabka@suse.cz
Subject: Re: poisoned pages do not play well in the buddy allocator
Message-ID: <20190826111414.GG7538@dhcp22.suse.cz>
References: <20190826104144.GA7849@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826104144.GA7849@linux>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 26-08-19 12:41:50, Oscar Salvador wrote:
[...]
> I checked [1], and it seems that [2] was going towards fixing this kind of issue.
> 
> I think it is about time to revamp the whole thing.

I completely agree. The current state of hwpoison is just too fragile to
be practically usable. We keep getting bug reports (as pointed out by
Oscar) when people try to test this via soft offlining. 

> @Naoya: I could give it a try if you are busy.

That would be more than appreciated. I feel guilty to have it slip
between cracks but I simply couldn't have found enough time to give it a
serious look. Sorry about that.

> [1] https://lore.kernel.org/linux-mm/1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com/
> [2] https://lore.kernel.org/linux-mm/1541746035-13408-9-git-send-email-n-horiguchi@ah.jp.nec.com/

-- 
Michal Hocko
SUSE Labs

