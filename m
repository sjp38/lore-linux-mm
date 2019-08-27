Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2DE9C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 14:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9066A214DA
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 14:10:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9066A214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAC4E6B0003; Tue, 27 Aug 2019 10:10:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5CB36B0008; Tue, 27 Aug 2019 10:10:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4B0D6B000A; Tue, 27 Aug 2019 10:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id B52656B0003
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 10:10:55 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B7A6E82437D2
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:10:19 +0000 (UTC)
X-FDA: 75868392558.20.music51_2cea47bd2a26
X-HE-Tag: music51_2cea47bd2a26
X-Filterd-Recvd-Size: 2684
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:10:19 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2E2ACB022;
	Tue, 27 Aug 2019 14:10:17 +0000 (UTC)
Date: Tue, 27 Aug 2019 16:10:16 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Thomas Backlund <tmb@mageia.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Greg KH <greg@kroah.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Yafang Shao <laoar.shao@gmail.com>
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM
 counters in sync with the hierarchical ones"
Message-ID: <20190827141016.GH7538@dhcp22.suse.cz>
References: <20190817004726.2530670-1-guro@fb.com>
 <20190817063616.GA11747@kroah.com>
 <20190817191518.GB11125@castle>
 <20190824125750.da9f0aac47cc0a362208f9ff@linux-foundation.org>
 <a082485b-8241-e73d-df09-5c878d181ddc@mageia.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a082485b-8241-e73d-df09-5c878d181ddc@mageia.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 24-08-19 23:23:07, Thomas Backlund wrote:
> Den 24-08-2019 kl. 22:57, skrev Andrew Morton:
> > On Sat, 17 Aug 2019 19:15:23 +0000 Roman Gushchin <guro@fb.com> wrote:
> > 
> > > > > Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
> > > > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > > > Cc: Yafang Shao <laoar.shao@gmail.com>
> > > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > > ---
> > > > >   mm/memcontrol.c | 8 +++-----
> > > > >   1 file changed, 3 insertions(+), 5 deletions(-)
> > > > 
> > > > <formletter>
> > > > 
> > > > This is not the correct way to submit patches for inclusion in the
> > > > stable kernel tree.  Please read:
> > > >      https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
> > > > for how to do this properly.
> > > 
> > > Oh, I'm sorry, will read and follow next time. Thanks!
> > 
> > 766a4c19d880 is not present in 5.2 so no -stable backport is needed, yes?
> > 
> 
> Unfortunately it got added in 5.2.7, so backport is needed.

yet another example of patch not marked for stable backported to the
stable tree. yay...

-- 
Michal Hocko
SUSE Labs

