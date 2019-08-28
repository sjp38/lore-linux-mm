Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEF17C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 10:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E3CD22CF8
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 10:32:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E3CD22CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3026A6B0008; Wed, 28 Aug 2019 06:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B2766B000C; Wed, 28 Aug 2019 06:32:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EF8E6B000D; Wed, 28 Aug 2019 06:32:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0156.hostedemail.com [216.40.44.156])
	by kanga.kvack.org (Postfix) with ESMTP id EB8F46B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 06:32:15 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8DB98824CA3B
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:32:15 +0000 (UTC)
X-FDA: 75871471830.20.drink53_30c7a3e3b071e
X-HE-Tag: drink53_30c7a3e3b071e
X-Filterd-Recvd-Size: 3218
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:32:15 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 434A7AFBE;
	Wed, 28 Aug 2019 10:32:13 +0000 (UTC)
Date: Wed, 28 Aug 2019 12:32:11 +0200
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
Message-ID: <20190828103211.GD28313@dhcp22.suse.cz>
References: <20190826193638.6638-1-echron@arista.com>
 <1566909632.5576.14.camel@lca.pw>
 <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
 <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw>
 <CAM3twVSdxJaEpmWXu2m_F1MxFMB58C6=LWWCDYNn5yT3Ns+0sQ@mail.gmail.com>
 <2A1D8FFC-9E9E-4D86-9A0E-28F8263CC508@lca.pw>
 <CAM3twVR5TVuuZSLM2qRJYnkCEKVZmA3XDNREaB+wdKH2Ne9vVA@mail.gmail.com>
 <20190828070845.GC7386@dhcp22.suse.cz>
 <2e816b05-7b5b-4bc0-8d38-8415daea920d@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2e816b05-7b5b-4bc0-8d38-8415daea920d@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 28-08-19 19:12:41, Tetsuo Handa wrote:
> On 2019/08/28 16:08, Michal Hocko wrote:
> > On Tue 27-08-19 19:47:22, Edward Chron wrote:
> >> For production systems installing and updating EBPF scripts may someday
> >> be very common, but I wonder how data center managers feel about it now?
> >> Developers are very excited about it and it is a very powerful tool but can I
> >> get permission to add or replace an existing EBPF on production systems?
> > 
> > I am not sure I understand. There must be somebody trusted to take care
> > of systems, right?
> > 
> 
> Speak of my cases, those who take care of their systems are not developers.
> And they afraid changing code that runs in kernel mode. They unlikely give
> permission to install SystemTap/eBPF scripts. As a result, in many cases,
> the root cause cannot be identified.

Which is something I would call a process problem more than a kernel
one. Really if you need to debug a problem you really have to trust
those who can debug that for you. We are not going to take tons of code
to the kernel just because somebody is afraid to run a diagnostic.

> Moreover, we are talking about OOM situations, where we can't expect userspace
> processes to work properly. We need to dump information we want, without
> counting on userspace processes, before sending SIGKILL.

Yes, this is an inherent assumption I was making and that means that
whatever dynamic hooks would have to be registered in advance.

-- 
Michal Hocko
SUSE Labs

