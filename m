Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E90F4C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 11:12:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BF2E2189D
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 11:12:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BF2E2189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26F006B0008; Wed, 28 Aug 2019 07:12:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21F6B6B000C; Wed, 28 Aug 2019 07:12:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1351F6B000D; Wed, 28 Aug 2019 07:12:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0108.hostedemail.com [216.40.44.108])
	by kanga.kvack.org (Postfix) with ESMTP id E5B7F6B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:12:53 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A6638610C
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 11:12:53 +0000 (UTC)
X-FDA: 75871574226.07.crow09_70837d130e93f
X-HE-Tag: crow09_70837d130e93f
X-Filterd-Recvd-Size: 4067
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 11:12:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 622BEAF0B;
	Wed, 28 Aug 2019 11:12:49 +0000 (UTC)
Date: Wed, 28 Aug 2019 13:12:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Edward Chron <echron@arista.com>, Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
Message-ID: <20190828111248.GE28313@dhcp22.suse.cz>
References: <1566909632.5576.14.camel@lca.pw>
 <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
 <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw>
 <CAM3twVSdxJaEpmWXu2m_F1MxFMB58C6=LWWCDYNn5yT3Ns+0sQ@mail.gmail.com>
 <2A1D8FFC-9E9E-4D86-9A0E-28F8263CC508@lca.pw>
 <CAM3twVR5TVuuZSLM2qRJYnkCEKVZmA3XDNREaB+wdKH2Ne9vVA@mail.gmail.com>
 <20190828070845.GC7386@dhcp22.suse.cz>
 <2e816b05-7b5b-4bc0-8d38-8415daea920d@i-love.sakura.ne.jp>
 <20190828103211.GD28313@dhcp22.suse.cz>
 <5db2d2bd-645b-8967-849a-0d1de5861742@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5db2d2bd-645b-8967-849a-0d1de5861742@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 28-08-19 19:56:58, Tetsuo Handa wrote:
> On 2019/08/28 19:32, Michal Hocko wrote:
> >> Speak of my cases, those who take care of their systems are not developers.
> >> And they afraid changing code that runs in kernel mode. They unlikely give
> >> permission to install SystemTap/eBPF scripts. As a result, in many cases,
> >> the root cause cannot be identified.
> > 
> > Which is something I would call a process problem more than a kernel
> > one. Really if you need to debug a problem you really have to trust
> > those who can debug that for you. We are not going to take tons of code
> > to the kernel just because somebody is afraid to run a diagnostic.
> > 
> 
> This is a problem of kernel development process.

I disagree. Expecting that any larger project can be filled with the
(close to) _full_ and ready to use introspection built in is just
insane. We are trying to help with a generally useful information but
you simply cannot cover most existing failure paths.

> >> Moreover, we are talking about OOM situations, where we can't expect userspace
> >> processes to work properly. We need to dump information we want, without
> >> counting on userspace processes, before sending SIGKILL.
> > 
> > Yes, this is an inherent assumption I was making and that means that
> > whatever dynamic hooks would have to be registered in advance.
> > 
> 
> No. I'm saying that neither static hooks nor dynamic hooks can work as
> expected if they count on userspace processes. Registering in advance is
> irrelevant. Whether it can work without userspace processes is relevant.

I am not saying otherwise. I do not expect any userspace process to dump
any information or read it from elswhere than from the kernel log.

> Also, out-of-tree codes tend to become defunctional. We are trying to debug
> problems caused by in-tree code. Breaking out-of-tree debugging code just
> because in-tree code developers don't want to pay the burden of maintaining
> code for debugging problems caused by in-tree code is a very bad idea.

This is a simple math of cost/benefit. The maintenance cost is not free
and paying it for odd cases most people do not care about is simply not
sustainable, we simply do not have that much of a man power.
-- 
Michal Hocko
SUSE Labs

