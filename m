Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B4C7C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07EFF20870
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07EFF20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA4F06B0007; Wed,  4 Sep 2019 01:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7CBC6B000E; Wed,  4 Sep 2019 01:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B9EA6B0010; Wed,  4 Sep 2019 01:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1756B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 01:40:08 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 23DE9824CA3E
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:40:08 +0000 (UTC)
X-FDA: 75896137296.07.cork60_587223bab5905
X-HE-Tag: cork60_587223bab5905
X-Filterd-Recvd-Size: 1848
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:40:07 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 07E7CADC4;
	Wed,  4 Sep 2019 05:40:06 +0000 (UTC)
Date: Wed, 4 Sep 2019 07:40:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
Message-ID: <20190904054004.GA3838@dhcp22.suse.cz>
References: <20190903144512.9374-1-mhocko@kernel.org>
 <af0703d2-17e4-1b8e-eb54-58d7743cad60@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af0703d2-17e4-1b8e-eb54-58d7743cad60@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 05:52:43, Tetsuo Handa wrote:
> On 2019/09/03 23:45, Michal Hocko wrote:
> > It's primary purpose is
> > to help analyse oom victim selection decision.
> 
> I disagree, for I use the process list for understanding what / how many
> processes are consuming what kind of memory (without crashing the system)
> for anomaly detection purpose. Although we can't dump memory consumed by
> e.g. file descriptors, disabling dump_tasks() loose that clue, and is
> problematic for me.

Does anything really prevent you from enabling this by sysctl though? Or
do you claim that this is a general usage pattern and therefore the
default change is not acceptable or do you want a changelog to be
updated?

-- 
Michal Hocko
SUSE Labs

