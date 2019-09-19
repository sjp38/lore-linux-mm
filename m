Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18005C4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 08:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB4DE21848
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 08:23:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB4DE21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79E446B0349; Thu, 19 Sep 2019 04:23:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727DE6B034A; Thu, 19 Sep 2019 04:23:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 616166B034B; Thu, 19 Sep 2019 04:23:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9386B0349
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 04:23:58 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C18C26120
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 08:23:57 +0000 (UTC)
X-FDA: 75950982114.23.iron74_3fa980a24be0c
X-HE-Tag: iron74_3fa980a24be0c
X-Filterd-Recvd-Size: 2505
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 08:23:57 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 720C0AFA8;
	Thu, 19 Sep 2019 08:23:55 +0000 (UTC)
Date: Thu, 19 Sep 2019 10:23:54 +0200
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
Message-ID: <20190919082354.GC15782@dhcp22.suse.cz>
References: <20190918095159.27098-1-linf@wangsu.com>
 <20190918122738.GE12770@dhcp22.suse.cz>
 <c5f278da-ec68-3206-d91b-d1ca7c97bb8c@wangsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c5f278da-ec68-3206-d91b-d1ca7c97bb8c@wangsu.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 19-09-19 09:32:48, Lin Feng wrote:
> 
> 
> On 9/18/19 20:27, Michal Hocko wrote:
> > Please do not post a new version with a minor compile fixes until there
> > is a general agreement on the approach. Willy had comments which really
> > need to be resolved first.
> 
> Sorry, but thanks for pointing out.
> 
> > 
> > Also does this
> > [...]
> > > Reported-by: kbuild test robot<lkp@intel.com>
> > really hold? Because it suggests that the problem has been spotted by
> > the kbuild bot which is kinda unexpected... I suspect you have just
> > added that for the minor compilation issue that you have fixed since the
> > last version.
> 
> Yes, I do know the issue is not reported by the robot, but
> just followed the kbuild robot tip, this Reported-by suggested by kbuild robot
> seems a little misleading, I'm not sure if it has other meanings.
> 'If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>'

This would be normally the case for a patch which only fixes the
particular issue. You can credit the bot in the changelog while
documenting changes between version.

-- 
Michal Hocko
SUSE Labs

