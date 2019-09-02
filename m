Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C587FC3A59B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:27:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A09CE23774
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:27:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A09CE23774
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A99B6B0003; Mon,  2 Sep 2019 03:27:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 333406B0006; Mon,  2 Sep 2019 03:27:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 222936B0007; Mon,  2 Sep 2019 03:27:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id EE9376B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 03:27:18 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8C61662FF
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:27:18 +0000 (UTC)
X-FDA: 75889149756.22.offer27_22aa9c4ceab5c
X-HE-Tag: offer27_22aa9c4ceab5c
X-Filterd-Recvd-Size: 1380
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:27:18 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BF6B1ADFE;
	Mon,  2 Sep 2019 07:27:16 +0000 (UTC)
Date: Mon, 2 Sep 2019 09:27:16 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Thomas Lindroth <thomas.lindroth@gmail.com>
Cc: linux-mm@kvack.org, stable@vger.kernel.org
Subject: Re: [BUG] Early OOM and kernel NULL pointer dereference in 4.19.69
Message-ID: <20190902072716.GD14028@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <20190902071617.GC14028@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902071617.GC14028@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 02-09-19 09:16:17, Michal Hocko wrote:
> On Sun 01-09-19 22:43:05, Thomas Lindroth wrote:
> > After upgrading to the 4.19 series I've started getting problems with
> > early OOM.
> 
> What is the kenrel you have updated from? Would it be possible to try
> the current Linus' tree?

Btw. checking vanilla 4.19 without stable patches might be interesting
as well.
-- 
Michal Hocko
SUSE Labs

