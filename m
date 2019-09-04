Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24EEAC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:14:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF0D62339E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:14:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="QnuouqMm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF0D62339E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F8F86B0003; Wed,  4 Sep 2019 08:14:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A82E6B0006; Wed,  4 Sep 2019 08:14:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 670A96B0007; Wed,  4 Sep 2019 08:14:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECC06B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:14:27 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9BA07181AC9B6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:14:26 +0000 (UTC)
X-FDA: 75897130932.08.door90_26bb1ec03781d
X-HE-Tag: door90_26bb1ec03781d
X-Filterd-Recvd-Size: 5104
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:14:26 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id l22so11811469qtp.10
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 05:14:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bl6KGDbxyH9xibYLFzb2mGM47IhCp8dCBtbeKfHElvA=;
        b=QnuouqMmL8Ruk+R6jgbyEXsFKtEUI5jAhWEUccMzoIFT3hIMpBl5QgvXmfPajbeZgi
         d2iMXBHvzXkhD7THAH6LnGOC8s/EcsqTzcVeAI3UnGtcjpKZGJt9NPTdmm5cTcnuw2XO
         N7Hi3qrBbJdk3+mwG9Milp6EEDXrhwxY1Uvt0wOyxopI4PH9pLEML/64jmM/Ls+0o47e
         ktXGLGHcIC5QGyLUWDJb1dIU4+DiP5SK1Z8QCMsBF1GWBujQzoXO1C5jS6EoUMD6kApL
         qjrI+wfMsyPkw9IUz1frp0Vpe+I20t/JM75jAVRP8cFXMe71o4zxTvut7gNWwNvoMf5a
         NXkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=bl6KGDbxyH9xibYLFzb2mGM47IhCp8dCBtbeKfHElvA=;
        b=SJGZVUE5XaJSOX1hgGFJZCRfWUXkM+AR+SbxLVa56HT7FHcTANmOP7gFTZLgO3qZGX
         ZH5RtnLqBBXtYSL6s+IS/y4AV4fpp7oA89mnYPUTMN7vyBbtRU5l5riyAdYX1odjNkS0
         RjGN/Qb0C98IaAt1MIZ4S5zh9Fb7qilBvZuVVAE5+K0fsro3Fbtwk3WJw9yfC8lDXXjQ
         Vh+JwtZZ51BnRjMFOdHMjSqWy1oJ5q9JffUKpX6ccAb4FOJqFi00WSN/L1JyO5CvZz6f
         EfzqNVboo8ul6zqX6PvkIvjCybku9fm8K3fRFH2tdwr1eRPc535Jdco7ahrZuIAXu0hP
         NOHA==
X-Gm-Message-State: APjAAAUJ+cUL5yuGnIWzan7KWvd6slM4ZIUQI9Cy5X2JFfqJzRykwiQO
	fssZeFXv0BhkakB8scDvx6Qb2A6j3uY=
X-Google-Smtp-Source: APXvYqwVMedOXPfbW97QL3Tml18XfuCAjaFmLYqEjgyl13jtOyVoXSys9SE3TEG9CouaQn2bE7sZGw==
X-Received: by 2002:a0c:8ad0:: with SMTP id 16mr14055557qvw.237.1567599265215;
        Wed, 04 Sep 2019 05:14:25 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 29sm7794713qkp.86.2019.09.04.05.14.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 05:14:24 -0700 (PDT)
Message-ID: <1567599263.5576.72.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko
	 <mhocko@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net, 
 netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky
 <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 04 Sep 2019 08:14:23 -0400
In-Reply-To: <20190904074312.GA25744@jagdpanzerIV>
References: <1567178728.5576.32.camel@lca.pw>
	 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
	 <20190903132231.GC18939@dhcp22.suse.cz> <1567525342.5576.60.camel@lca.pw>
	 <20190903185305.GA14028@dhcp22.suse.cz> <1567546948.5576.68.camel@lca.pw>
	 <20190904061501.GB3838@dhcp22.suse.cz> <20190904064144.GA5487@jagdpanzerIV>
	 <20190904065455.GE3838@dhcp22.suse.cz>
	 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 16:43 +0900, Sergey Senozhatsky wrote:
> On (09/04/19 16:19), Sergey Senozhatsky wrote:
> > Hmm. I need to look at this more... wake_up_klogd() queues work only =
once
> > on particular CPU: irq_work_queue(this_cpu_ptr(&wake_up_klogd_work));
> >=20
> > bool irq_work_queue()
> > {
> > 	/* Only queue if not already pending */
> > 	if (!irq_work_claim(work))
> > 		return false;
> >=20
> > 	 __irq_work_queue_local(work);
> > }
>=20
> Plus one more check - waitqueue_active(&log_wait). printk() adds
> pending irq_work only if there is a user-space process sleeping on
> log_wait and irq_work is not already scheduled. If the syslog is
> active or there is noone to wakeup then we don't queue irq_work.

Another possibility for this potential livelock is that those printk() fr=
om
warn_alloc(), dump_stack() and show_mem() increase the time it needs to p=
rocess
build_skb() allocation failures significantly under memory pressure. As t=
he
result, ksoftirqd() could be rescheduled during that time via a different=
 CPU
(this is a large x86 NUMA system anyway),

[83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0run_ksoftirqd+0x1f/0x40
[83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0smpboot_thread_fn+0x255/=
0x440
[83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0kthread+0x1df/0x200
[83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0ret_from_fork+0x35/0x40

In addition, those printk() will deal with console drivers or even a netw=
orking
console, so it is probably not unusual that it could call irq_exit()-
>__do_softirq() at one point and then this livelock.

