Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9DA4C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:27:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 937F7205F4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:27:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 937F7205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BB756B0299; Wed, 18 Sep 2019 08:27:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26B106B029A; Wed, 18 Sep 2019 08:27:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15AE76B029B; Wed, 18 Sep 2019 08:27:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id E98246B0299
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 08:27:43 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8C730AC14
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:27:43 +0000 (UTC)
X-FDA: 75947967606.17.dust38_607eeb0540b19
X-HE-Tag: dust38_607eeb0540b19
X-Filterd-Recvd-Size: 1801
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:27:42 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2E57EAD78;
	Wed, 18 Sep 2019 12:27:41 +0000 (UTC)
Date: Wed, 18 Sep 2019 14:27:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Lin Feng <linf@wangsu.com>
Cc: corbet@lwn.net, mcgrof@kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	keescook@chromium.org, mchehab+samsung@kernel.org,
	mgorman@techsingularity.net, vbabka@suse.cz, ktkhai@virtuozzo.com,
	hannes@cmpxchg.org, willy@infradead.org,
	kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] [RESEND] vmscan.c: add a sysctl entry for controlling
 memory reclaim IO congestion_wait length
Message-ID: <20190918122738.GE12770@dhcp22.suse.cz>
References: <20190918095159.27098-1-linf@wangsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918095159.27098-1-linf@wangsu.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Please do not post a new version with a minor compile fixes until there
is a general agreement on the approach. Willy had comments which really
need to be resolved first. And I do agree with him. Having an explicit
tunable seems just wrong.

Also does this
[...]
> Reported-by: kbuild test robot <lkp@intel.com>

really hold? Because it suggests that the problem has been spotted by
the kbuild bot which is kinda unexpected... I suspect you have just
added that for the minor compilation issue that you have fixed since the
last version.
-- 
Michal Hocko
SUSE Labs

