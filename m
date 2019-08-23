Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DBEEC3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 12:12:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EC2A22CEC
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 12:12:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="TO/zMCga"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EC2A22CEC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B24A96B039A; Fri, 23 Aug 2019 08:12:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD5F56B039C; Fri, 23 Aug 2019 08:12:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ECBC6B039D; Fri, 23 Aug 2019 08:12:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0032.hostedemail.com [216.40.44.32])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF276B039A
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 08:12:37 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2255E6129
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 12:12:37 +0000 (UTC)
X-FDA: 75853580754.16.ice06_33e3984047f20
X-HE-Tag: ice06_33e3984047f20
X-Filterd-Recvd-Size: 5730
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 12:12:36 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id j15so10865530qtl.13
        for <linux-mm@kvack.org>; Fri, 23 Aug 2019 05:12:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uHLV+X5Nu9kdupcLl6QyNhVoeF56IJpkiVx881w4xyU=;
        b=TO/zMCgaYxZo8mC7MiMyiIF5tf8rjPTmanAanDvQkRfnbdCtKCevQPRbWd30bsadL2
         9Ks4DuTp1VCXO9mhwea6ttz7dnvJMBATPR9Fjglzo+36gxOQ00sgsRCizYSPBXboKf0P
         i2BRx0IeNyOFZzI6ziBwFsDsH3U9aXTACwWZTmlgo3HvfXzT8KPFlXYHC5eHnTWbAjE2
         QqRczwJcJCvH3YN1DzJ4O2XlJEXAeouxe/lBDWIjmhVOlu6fjv2XOegsktNMwd89HgN2
         MEcz4o79i/h8U1i77EnDu2UhWMDKpyr9rxiAS7PYVa2mu38BZ+KxgHkHNpVCjNeccg3J
         W1fQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=uHLV+X5Nu9kdupcLl6QyNhVoeF56IJpkiVx881w4xyU=;
        b=ug/ZW9wz5k2WwWk/rJEZKSLihIXKMPCygANm7VYVFxvySBjrmM+a1GQhpU3iETLgkM
         ebFEUb1y78M7ip2Qy0rMteHeLN+L+NUvrHe9thboJ6poSoJ1hH+/tKQ9zJt/l2OIiDGn
         MDfO/h/V9ppZ1u+Y/J5BlHHPtSU20ZxJJzVzuHdjK/g+i03r3dOPQ47128/2FCE53pMR
         3RAjbgTSMg7X21H/iROhxZePec+Rtu6vo+98DnkIObHTR1N0OykAS9o8uR9q8ol72F1q
         U3QAu7+7u7Fw/ErrRVmhfFRbTjTdWHsi6YuKoRGX0Kn7cgD+mHhkvxT8gQozFfdj3P5q
         JyVA==
X-Gm-Message-State: APjAAAXgoCBd6dd/PusE0A73AgbL5XWIp9mAR34s+uX1HpkNHEwrFiiX
	+iC82+dAprI+6QRhXRERwR+CKQ==
X-Google-Smtp-Source: APXvYqwHikON40QpW/kDe9S7FvkTB91Qpt5C6QNw74RFU0iIZjGQK6gl0/y64UkxpkoC7JC1nUa4Pw==
X-Received: by 2002:a0c:e64d:: with SMTP id c13mr3551719qvn.80.1566562355919;
        Fri, 23 Aug 2019 05:12:35 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c23sm1110853qtp.3.2019.08.23.05.12.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Aug 2019 05:12:35 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i18Qk-0003fK-Vg; Fri, 23 Aug 2019 09:12:34 -0300
Date: Fri, 23 Aug 2019 09:12:34 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
Message-ID: <20190823121234.GB12968@ziepe.ca>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-4-daniel.vetter@ffwll.ch>
 <20190820202440.GH11147@phenom.ffwll.local>
 <20190822161428.c9e4479207386d34745ea111@linux-foundation.org>
 <CAKMK7uGw_7uD=wH3bcR9xXSxAcAuYTLOZt3ue4TEvst1D0KzLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uGw_7uD=wH3bcR9xXSxAcAuYTLOZt3ue4TEvst1D0KzLQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 10:34:01AM +0200, Daniel Vetter wrote:
> On Fri, Aug 23, 2019 at 1:14 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Tue, 20 Aug 2019 22:24:40 +0200 Daniel Vetter <daniel@ffwll.ch> wrote:
> >
> > > Hi Peter,
> > >
> > > Iirc you've been involved at least somewhat in discussing this. -mm folks
> > > are a bit undecided whether these new non_block semantics are a good idea.
> > > Michal Hocko still is in support, but Andrew Morton and Jason Gunthorpe
> > > are less enthusiastic. Jason said he's ok with merging the hmm side of
> > > this if scheduler folks ack. If not, then I'll respin with the
> > > preempt_disable/enable instead like in v1.
> >
> > I became mollified once Michel explained the rationale.  I think it's
> > OK.  It's very specific to the oom reaper and hopefully won't be used
> > more widely(?).
> 
> Yeah, no plans for that from me. And I hope the comment above them now
> explains why they exist, so people think twice before using it in
> random places.

I still haven't heard a satisfactory answer why a whole new scheme is
needed and a simple:

   if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP))
        preempt_disable()

isn't sufficient to catch the problematic cases during debugging??
IMHO the fact preempt is changed by the above when debugging is not
material here. I think that information should be included in the
commit message at least.

But if sched people are happy then lets go ahead. Can you send a v2
with the check encompassing the invalidate_range_end?

Jason

