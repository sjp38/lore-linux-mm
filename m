Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57C8DC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:07:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E79322CF7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:07:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jHZXAogL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E79322CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF8756B0007; Wed,  4 Sep 2019 11:07:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA9476B0008; Wed,  4 Sep 2019 11:07:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C0256B000A; Wed,  4 Sep 2019 11:07:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3946B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:07:24 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2CC47A2C2
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:07:24 +0000 (UTC)
X-FDA: 75897566808.14.print30_5d9fee480a223
X-HE-Tag: print30_5d9fee480a223
X-Filterd-Recvd-Size: 5909
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:07:23 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id b2so21259587qtq.5
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 08:07:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Bjd/DHxyfRBfNYOym7ZeBY5xHPB82GB3Jq5Tu5oVy78=;
        b=jHZXAogLqBHGjDRqzv2BE9ym48eXzz+4o6+zbnl+BwInpdYGrRMShVv8qzdexPoeb/
         vYXQ4ajKw3a/n5aBNC4VhSsCICv9XUxTmuUodSeshCk4Cco25QaHvg6dnhQz8fosfgQW
         GdcmtgH1mepQHwWgJSzdsueMoCHstNRvLxQsljKBxCFAg5cGuLGIs154VmP0Ux4TBYYy
         w7zfMEPdPGk3xYXlT/cpYNjKULaAWUvaGi/iHkRX2uHJFAJX5hHbo0tbzy81ZReiW+07
         hNNIika7P41kvG85V6UeleEL6El+xVcQL5hTfUbrSzmikyiZQQ2jC3RJ6tCSe3DTHqnZ
         pQqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Bjd/DHxyfRBfNYOym7ZeBY5xHPB82GB3Jq5Tu5oVy78=;
        b=fnRwaH8D7BaixbF9LAo4VwU9iB5kTxvphKQ48xf+k8XtP93m1U3Rvz67ItcLSYop5U
         VlXYAC436Ecsw2jJ0y1xXTrfT3xlI+YxABbPmscMnLsxr+rDB94xd500371avvjKgDqb
         ieOacgqF9wsYzhi1Rm0//XCiJ9qIpIvwlJ9yNEXdF1UFZsLozuj9xX8T46wHRxoW9zbI
         WL3Wss69Ipo/R9pHI8G+UaIMW3PQWj98ekpra6Wgtz2Sn9Ynlo14+GefMWghMYAWqvCz
         UhjTmY+GVRnI3bGTsrq0sftKVZqxtYhwPMmmjusBzdF8PHxpqBDnbY2SZgZ4wdRjMCIT
         S/Qg==
X-Gm-Message-State: APjAAAXPyhXyEE8DIfLzH8oSfzV+OKLK/Dht0zEbXYZG3YtkgHq7LMku
	d/ccdjth4k67jJFp62zv07mJjg==
X-Google-Smtp-Source: APXvYqyUFuGuP1OqyDPej1C7+ccIcKNGMcWn7j0roB5W+o42SqyZvE7l4bW0iAC0eogfNCEovjMcag==
X-Received: by 2002:ac8:295d:: with SMTP id z29mr40394176qtz.168.1567609642691;
        Wed, 04 Sep 2019 08:07:22 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id k54sm1027434qtf.28.2019.09.04.08.07.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 08:07:22 -0700 (PDT)
Message-ID: <1567609639.5576.79.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko
 <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
 davem@davemloft.net,  netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Steven
 Rostedt <rostedt@goodmis.org>
Date: Wed, 04 Sep 2019 11:07:19 -0400
In-Reply-To: <20190904144850.GA8296@tigerII.localdomain>
References: <20190903132231.GC18939@dhcp22.suse.cz>
	 <1567525342.5576.60.camel@lca.pw> <20190903185305.GA14028@dhcp22.suse.cz>
	 <1567546948.5576.68.camel@lca.pw> <20190904061501.GB3838@dhcp22.suse.cz>
	 <20190904064144.GA5487@jagdpanzerIV> <20190904065455.GE3838@dhcp22.suse.cz>
	 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
	 <1567599263.5576.72.camel@lca.pw>
	 <20190904144850.GA8296@tigerII.localdomain>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 23:48 +0900, Sergey Senozhatsky wrote:
> On (09/04/19 08:14), Qian Cai wrote:
> > > Plus one more check - waitqueue_active(&log_wait). printk() adds
> > > pending irq_work only if there is a user-space process sleeping on
> > > log_wait and irq_work is not already scheduled. If the syslog is
> > > active or there is noone to wakeup then we don't queue irq_work.
> >=20
> > Another possibility for this potential livelock is that those printk(=
) from
> > warn_alloc(), dump_stack() and show_mem() increase the time it needs =
to
> > process
> > build_skb() allocation failures significantly under memory pressure. =
As the
> > result, ksoftirqd() could be rescheduled during that time via a diffe=
rent
> > CPU
> > (this is a large x86 NUMA system anyway),
> >=20
> > [83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0run_ksoftirqd+0x1f/0=
x40
> > [83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0smpboot_thread_fn+0x=
255/0x440
> > [83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0kthread+0x1df/0x200
> > [83605.577256][=C2=A0=C2=A0=C2=A0C31]=C2=A0=C2=A0ret_from_fork+0x35/0=
x40
>=20
> Hum hum hum...
>=20
> So I can, _probably_, think of several patches.
>=20
> First, move wake_up_klogd() back to console_unlock().
>=20
> Second, move `printk_pending' out of per-CPU region and make it global.
> So we will have just one printk irq_work scheduled across all CPUs;
> currently we have one irq_work per CPU. I think I sent a patch a long
> long time ago, but we never discussed it, as far as I remember.
>=20
> > In addition, those printk() will deal with console drivers or even a
> > networking
> > console, so it is probably not unusual that it could call irq_exit()-
> > __do_softirq() at one point and then this livelock.
>=20
> Do you use netcon? Because this, theoretically, can open up one more
> vector. netcon allocates skbs from ->write() path. We call con drivers'
> ->write() from printk_safe context, so should netcon skb allocation
> warn we will scedule one more irq_work on that CPU to flush per-CPU
> printk_safe buffer.

No, I don't use netcon. Just thought to mention it anyway since there cou=
ld
other people use it.

>=20
> If this is the case, then we can stop calling console_driver() under
> printk_safe. I sent a patch a while ago, but we agreed to keep the
> things the way they are, fot the time being.
>=20
> Let me think more.
>=20
> 	-ss

