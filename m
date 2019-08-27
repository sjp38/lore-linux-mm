Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B9C8C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:55:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEBFB2077B
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:55:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEBFB2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51FF66B0005; Tue, 27 Aug 2019 08:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D1036B0008; Tue, 27 Aug 2019 08:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E7256B000A; Tue, 27 Aug 2019 08:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2C66B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:55:27 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BA98B55F9D
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:55:26 +0000 (UTC)
X-FDA: 75868203852.14.play44_4c98bc794c504
X-HE-Tag: play44_4c98bc794c504
X-Filterd-Recvd-Size: 3826
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:55:26 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B187B62C;
	Tue, 27 Aug 2019 12:55:24 +0000 (UTC)
Date: Tue, 27 Aug 2019 14:55:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	Adric Blake <promarbler14@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Subject: Re: WARNINGs in set_task_reclaim_state with memory cgroup and full
 memory usage
Message-ID: <20190827125521.GE7538@dhcp22.suse.cz>
References: <CAE1jjeePxYPvw1mw2B3v803xHVR_BNnz0hQUY_JDMN8ny29M6w@mail.gmail.com>
 <b9cd7603-2441-d351-156a-57d6c13b2c79@linux.alibaba.com>
 <20190826105521.GF7538@dhcp22.suse.cz>
 <20190827104313.GW7538@dhcp22.suse.cz>
 <CALOAHbBMWyPBw+Ciup4+YupbLrxcTW76w+Mfc-mGEm9kcWb8YQ@mail.gmail.com>
 <20190827115014.GZ7538@dhcp22.suse.cz>
 <CALOAHbAtuQFB=GC41ZgSLXxheaEY4yz=fO9Zr5=rvTnyOYjF3A@mail.gmail.com>
 <20190827120335.GA7538@dhcp22.suse.cz>
 <CALOAHbDbNxg1xxZAT0rf3=46DrM1PV2YEDEP6F9HMU9JvgvESA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbDbNxg1xxZAT0rf3=46DrM1PV2YEDEP6F9HMU9JvgvESA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 20:19:34, Yafang Shao wrote:
> On Tue, Aug 27, 2019 at 8:03 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 27-08-19 19:56:16, Yafang Shao wrote:
> > > On Tue, Aug 27, 2019 at 7:50 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Tue 27-08-19 19:43:49, Yafang Shao wrote:
> > > > > On Tue, Aug 27, 2019 at 6:43 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > If there are no objection to the patch I will post it as a standalong
> > > > > > one.
> > > > >
> > > > > I have no objection to your patch. It could fix the issue.
> > > > >
> > > > > I still think that it is not proper to use a new scan_control here as
> > > > > it breaks the global reclaim context.
> > > > >
> > > > > This context switch from global reclaim to memcg reclaim is very
> > > > > subtle change to the subsequent processing, that may cause some
> > > > > unexpected behavior.
> > > >
> > > > Why would it break it? Could you be more specific please?
> > > >
> > >
> > > Hmm, I have explained it when replying to  Hillf's patch.
> > > The most suspcious one is settting target_mem_cgroup here, because we
> > > only use it to judge whether it is in global reclaim.
> > > While the memcg softlimit reclaim is really in global reclaims.
> >
> > But we are reclaim the target_mem_cgroup hierarchy. This is the whole
> > point of the soft reclaim. Push down that hierarchy below the configured
> > limit. And that is why we absolutely have to switch the reclaim context.
> >
> 
> One obvious issue is the reclaim couters may not correct.
> See shrink_inactive_list().
> The pages relcaimed in memcg softlimit will not be counted to
> PGSCAN_{DIRECT, KSWAPD} and PGSTEAL_{DIRECT, KSWAPD}.

And again this a long term behavior so I would be really curious why it
is considered a bug now. Really, the semantic of the soft limit is
weird. It has been grafted into the reclaim while it was doing a
semantically different thing. It doesn't really reflect kswapd or direct
reclaim targets.
-- 
Michal Hocko
SUSE Labs

