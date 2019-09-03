Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57F42C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 19:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 309CD217D7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 19:36:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 309CD217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5DF86B0005; Tue,  3 Sep 2019 15:36:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0EDF6B0006; Tue,  3 Sep 2019 15:36:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A24A36B0007; Tue,  3 Sep 2019 15:36:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 80F6D6B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:36:06 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DEB3C824CA38
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 19:36:05 +0000 (UTC)
X-FDA: 75894615090.11.house84_353118f8dc82f
X-HE-Tag: house84_353118f8dc82f
X-Filterd-Recvd-Size: 1975
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 19:36:05 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 473FCADDA;
	Tue,  3 Sep 2019 19:36:04 +0000 (UTC)
Date: Tue, 3 Sep 2019 21:36:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Thomas Lindroth <thomas.lindroth@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
	stable@vger.kernel.org
Subject: Re: [BUG] Early OOM and kernel NULL pointer dereference in 4.19.69
Message-ID: <20190903193603.GF14028@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <20190902071617.GC14028@dhcp22.suse.cz>
 <a07da432-1fc1-67de-ae35-93f157bf9a7d@gmail.com>
 <20190903074132.GM14028@dhcp22.suse.cz>
 <84c47d16-ff5a-9af0-efd4-5ef78d302170@virtuozzo.com>
 <20190903122221.GV14028@dhcp22.suse.cz>
 <c8c3effe-753c-ce1d-60f4-7d6ff2845074@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c8c3effe-753c-ce1d-60f4-7d6ff2845074@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 20:20:20, Thomas Lindroth wrote:
[...]
> If kmem accounting is both broken, unfixable and cause kernel crashes when
> used why not remove it? Or perhaps disable it per default like
> cgroup.memory=nokmem or at least print a warning to dmesg if the user tries
> to user it in a way that cause crashes?

Well, cgroup v1 interfaces and implementation is mostly frozen and users
are advised to use v2 interface that doesn't suffer from this problem
because there is no separate kmem limit and both user and kernel charges
are tight to the same counter.

We can be more explicit about shortcomings in the documentation but in
general v1 is deprecated.

-- 
Michal Hocko
SUSE Labs

