Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B3D9C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 540322189D
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:09:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 540322189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF7DE6B0008; Wed, 28 Aug 2019 10:09:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D814D6B000C; Wed, 28 Aug 2019 10:09:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C97F46B000D; Wed, 28 Aug 2019 10:09:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id A2C6B6B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:09:41 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 25E2582437C9
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:09:41 +0000 (UTC)
X-FDA: 75872019762.06.wrist99_376a17d0c2604
X-HE-Tag: wrist99_376a17d0c2604
X-Filterd-Recvd-Size: 2325
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:09:40 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 50EFEAE92;
	Wed, 28 Aug 2019 14:09:39 +0000 (UTC)
Date: Wed, 28 Aug 2019 16:09:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Dan Williams <dan.j.williams@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
Subject: Re: [PATCH v2] fs/proc/page: Skip uninitialized page when iterating
 page structures
Message-ID: <20190828140938.GL28313@dhcp22.suse.cz>
References: <20190826124336.8742-1-longman@redhat.com>
 <20190827142238.GB10223@dhcp22.suse.cz>
 <20190828080006.GG7386@dhcp22.suse.cz>
 <8363a4ba-e26f-f88c-21fc-5dd1fe64f646@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8363a4ba-e26f-f88c-21fc-5dd1fe64f646@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 28-08-19 09:46:21, Waiman Long wrote:
> On 8/28/19 4:00 AM, Michal Hocko wrote:
> > On Tue 27-08-19 16:22:38, Michal Hocko wrote:
> >> Dan, isn't this something we have discussed recently?
> > This was http://lkml.kernel.org/r/20190725023100.31141-3-t-fukasawa@vx.jp.nec.com
> > and talked about /proc/kpageflags but this is essentially the same thing
> > AFAIU. I hope we get a consistent solution for both issues.
> >
> Yes, it is the same problem. The uninitialized page structure problem
> affects all the 3 /proc/kpage{cgroup,count,flags) files.
> 
> Toshiki's patch seems to fix it just for /proc/kpageflags, though.

Yup. I was arguing that whacking a mole kinda fix is far from good. Dan
had some arguments on why initializing those struct pages is a problem.
The discussion had a half open end though. I hoped that Dan would try
out the initialization side but I migh have misunderstood.
-- 
Michal Hocko
SUSE Labs

