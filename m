Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67054C43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30AC6206A3
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:23:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30AC6206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD79C6B0285; Thu,  5 Sep 2019 13:23:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B87EE6B0287; Thu,  5 Sep 2019 13:23:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9E046B0288; Thu,  5 Sep 2019 13:23:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0129.hostedemail.com [216.40.44.129])
	by kanga.kvack.org (Postfix) with ESMTP id 86AD36B0285
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:23:44 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2A685824CA2A
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:23:44 +0000 (UTC)
X-FDA: 75901539168.28.music03_20902917ab94f
X-HE-Tag: music03_20902917ab94f
X-Filterd-Recvd-Size: 2051
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:23:43 +0000 (UTC)
Received: from oasis.local.home (bl11-233-114.dsl.telepac.pt [85.244.233.114])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 419EF20693;
	Thu,  5 Sep 2019 17:23:41 +0000 (UTC)
Date: Thu, 5 Sep 2019 13:23:34 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Petr Mladek <pmladek@suse.com>, Sergey
 Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko
 <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
 davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190905132334.52b13d95@oasis.local.home>
In-Reply-To: <20190905113208.GA521@jagdpanzerIV>
References: <20190903185305.GA14028@dhcp22.suse.cz>
	<1567546948.5576.68.camel@lca.pw>
	<20190904061501.GB3838@dhcp22.suse.cz>
	<20190904064144.GA5487@jagdpanzerIV>
	<20190904065455.GE3838@dhcp22.suse.cz>
	<20190904071911.GB11968@jagdpanzerIV>
	<20190904074312.GA25744@jagdpanzerIV>
	<1567599263.5576.72.camel@lca.pw>
	<20190904144850.GA8296@tigerII.localdomain>
	<1567629737.5576.87.camel@lca.pw>
	<20190905113208.GA521@jagdpanzerIV>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Sep 2019 20:32:08 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> I think we can queue significantly much less irq_work-s from printk().
> 
> Petr, Steven, what do you think?

What if we just rate limit the wake ups of klogd? I mean, really, do we
need to keep calling wake up if it probably never even executed?

-- Steve

