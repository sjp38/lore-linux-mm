Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7970FC49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:32:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55D59208E4
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:32:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55D59208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00BE66B0007; Tue, 10 Sep 2019 06:32:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFE926B0008; Tue, 10 Sep 2019 06:32:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E145C6B000A; Tue, 10 Sep 2019 06:32:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id C0EB96B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:32:41 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 657B7180AD801
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:32:41 +0000 (UTC)
X-FDA: 75918647322.13.move92_51a67b4a5b853
X-HE-Tag: move92_51a67b4a5b853
X-Filterd-Recvd-Size: 1449
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:32:40 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D1B74ABED;
	Tue, 10 Sep 2019 10:32:39 +0000 (UTC)
Date: Tue, 10 Sep 2019 12:32:37 +0200
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 00/10] Hwpoison soft-offline rework
Message-ID: <20190910103233.GA14370@linux>
References: <20190910103016.14290-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 12:30:06PM +0200, Oscar Salvador wrote:
> 
> This patchset was based on Naoya's hwpoison rework [1], so thanks to him
> for the initial work.
> 
> This patchset aims to fix some issues laying in soft-offline handling,
> but it also takes the chance and takes some further steps to perform 
> cleanups and some refactoring as well.

Of course, this was meant to be a "RFC PATCH" and not a "PATCH", but
fat-fingers...

Sorry for the inconvenience.

-- 
Oscar Salvador
SUSE L3

