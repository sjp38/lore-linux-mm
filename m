Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B784C3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 10:38:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3CD2204EC
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 10:38:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3CD2204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 190B16B0005; Tue, 27 Aug 2019 06:38:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 141266B0006; Tue, 27 Aug 2019 06:38:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0303C6B0007; Tue, 27 Aug 2019 06:38:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id D895B6B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:38:30 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 86F062C1E
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 10:38:30 +0000 (UTC)
X-FDA: 75867858780.18.pump32_2d21a9f85613f
X-HE-Tag: pump32_2d21a9f85613f
X-Filterd-Recvd-Size: 2095
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 10:38:30 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56FC8AF2C;
	Tue, 27 Aug 2019 10:38:28 +0000 (UTC)
Date: Tue, 27 Aug 2019 12:38:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Edward Chron <echron@arista.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, colona@arista.com
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
Message-ID: <20190827103827.GV7538@dhcp22.suse.cz>
References: <20190826193638.6638-1-echron@arista.com>
 <20190827071523.GR7538@dhcp22.suse.cz>
 <5768394f-1511-5b00-f715-c0c5446a2d2a@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5768394f-1511-5b00-f715-c0c5446a2d2a@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 19:10:18, Tetsuo Handa wrote:
> On 2019/08/27 16:15, Michal Hocko wrote:
> > All that being said, I do not think this is something we want to merge
> > without a really _strong_ usecase to back it.
> 
> Like the sender's domain "arista.com" suggests, some of information is
> geared towards networking devices, and ability to report OOM information
> in a way suitable for automatic recording/analyzing (e.g. without using
> shell prompt, let alone manually typing SysRq commands) would be convenient
> for unattended devices.

Why cannot the remote end of the logging identify the host. It has to
connect somewhere anyway, right? I also do assume that a log collector
already does store each log with host id of some form.

-- 
Michal Hocko
SUSE Labs

