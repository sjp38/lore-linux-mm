Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5011C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:09:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6239F20578
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:09:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="juP160Fo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6239F20578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1406B0003; Fri,  6 Sep 2019 09:08:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E51CF6B0006; Fri,  6 Sep 2019 09:08:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D67876B0007; Fri,  6 Sep 2019 09:08:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id B3FFC6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:08:59 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6050B180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:08:59 +0000 (UTC)
X-FDA: 75904525998.20.cakes96_3143d96c31001
X-HE-Tag: cakes96_3143d96c31001
X-Filterd-Recvd-Size: 6223
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:08:58 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id i78so5495992qke.11
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 06:08:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vkVmH1p1DD1CPH+j4BlB7sfnBpEDKj82YtcyyFyFAco=;
        b=juP160FoYMWe9UKbeMdUpx83d8NX59ODPCOMXc0mviKzeloHkHKH5gf2E9/0woBZPa
         blEvgx6cfxKXnyDIcEqPFobhP7tmuFIs7Ym2RCvOjYUMIspzLrT8NNkA+RrXL8C0FIws
         fB+SNSjar4ofF4dmZcN4gD3tDzio3cEC2sj5JF3Py3Y17bQSBNiyPxl6n10J1uxBsZ4E
         UoCCY1tpqNMNOcFU0yltiO/gDZVA1uIapOCFIflQZ4dX3zD6jlgEG3otC8beXo/6feBy
         0cIyZI+hniLka6B1vnpz7avp4D0mfionOflerjAjX8oTq4YGGUrXQAJZvzld1wvE8pEH
         FbiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=vkVmH1p1DD1CPH+j4BlB7sfnBpEDKj82YtcyyFyFAco=;
        b=XCq2tk0LdFIM3uFoEJCe58nQqNsYrgkcBwQiJ1UfsJ+a3ayg9hdrDLkZ3iEtqiX0+O
         7ZorU38TopNW9gX6XqiMep+ODeMQGpbxmQqDorDBEEM4A3N5gi/gybPvnqi6wka6j7qL
         Jinkf0acxEBn/AtNWo1telj/D1LuieqWQWMvORWS3oVz0RTjtdbTWO5QZZW2SQOCB/7+
         HNpsLVrkegnhdKkva55aDnlggxUIuaG/8BNcWcgScsPby2zVA3hXjXHwPBT3p9boh2sQ
         55Jv/3m9k0yoJ6Gj/X/gyVMofTbRUiC5iS2EEgpeOZ9vJrrc046EjLWQhIbEBt/gqtbf
         tbNw==
X-Gm-Message-State: APjAAAVesQmYkL6sBHbO+pxX9armgnyCkOllBxrLWaavM0+X38+ePXz7
	EYVJg3Zv7buXHTVcNxS4QDLcFQ==
X-Google-Smtp-Source: APXvYqxNb8JNjg0hVKNLAzAks/AnxBjS1tDbyiktCl5kTm/kEcm/N5/l98cq8pxFQZdpU+s8rJLjIQ==
X-Received: by 2002:a37:410:: with SMTP id 16mr8576974qke.52.1567775337798;
        Fri, 06 Sep 2019 06:08:57 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id c19sm2249787qtj.39.2019.09.06.06.08.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 06:08:57 -0700 (PDT)
Message-ID: <1567775335.5576.110.camel@lca.pw>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
From: Qian Cai <cai@lca.pw>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>
Date: Fri, 06 Sep 2019 09:08:55 -0400
In-Reply-To: <192f2cb9-172e-06f4-d9e4-a58b5e167231@i-love.sakura.ne.jp>
References: <20190903144512.9374-1-mhocko@kernel.org>
	 <1567522966.5576.51.camel@lca.pw> <20190903151307.GZ14028@dhcp22.suse.cz>
	 <1567699853.5576.98.camel@lca.pw>
	 <8ea5da51-a1ac-4450-17d9-0ea7be346765@i-love.sakura.ne.jp>
	 <1567718475.5576.108.camel@lca.pw>
	 <192f2cb9-172e-06f4-d9e4-a58b5e167231@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-09-06 at 19:32 +0900, Tetsuo Handa wrote:
> On 2019/09/06 6:21, Qian Cai wrote:
> > On Fri, 2019-09-06 at 05:59 +0900, Tetsuo Handa wrote:
> > > On 2019/09/06 1:10, Qian Cai wrote:
> > > > On Tue, 2019-09-03 at 17:13 +0200, Michal Hocko wrote:
> > > > > On Tue 03-09-19 11:02:46, Qian Cai wrote:
> > > > > > Well, I still see OOM sometimes kills wrong processes like ssh, systemd
> > > > > > processes while LTP OOM tests with staight-forward allocation patterns.
> > > > > 
> > > > > Please report those. Most cases I have seen so far just turned out to
> > > > > work as expected and memory hogs just used oom_score_adj or similar.
> > > > 
> > > > Here is the one where oom01 should be one to be killed.
> > > 
> > > I assume that there are previous OOM killer events before
> > > 
> > > > 
> > > > [92598.855697][ T2588] Swap cache stats: add 105240923, delete 105250445, find
> > > > 42196/101577
> > > 
> > > line. Please be sure to include.
> > 
> > 12:00:52 oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0-1,global_oom,task_memcg=/user.slice,task=oom01,pid=25507,uid=0
> > 12:00:52 Out of memory: Killed process 25507(oom01) total-vm:6324780kB, anon-rss:5647168kB, file-rss:0kB, shmem-rss:0kB,UID:0 pgtables:11395072kB oom_score_adj:0
> > 12:00:52 oom_reaper: reaped process 25507(oom01), now anon-rss:5647452kB, file-rss:0kB, shmem-rss:0kB
> > 12:00:52 irqbalance invoked oom-killer: gfp_mask=0x100cca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
> > (...snipped...)
> > 12:00:53 [  25391]     0 25391     2184        0    65536       32             0 oom01
> > 12:00:53 [  25392]     0 25392     2184        0    65536       39             0 oom01
> > 12:00:53 oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0-1,global_oom,task_memcg=/system.slice/tuned.service,task=tuned,pid=2629,uid=0
> > 12:00:54 Out of memory: Killed process 2629(tuned) total-vm:424936kB, anon-rss:328kB, file-rss:1268kB, shmem-rss:0kB, UID:0 pgtables:442368kB oom_score_adj:0
> > 12:00:54 oom_reaper: reaped process 2629 (tuned), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
> OK. anon-rss did not decrease when oom_reaper gave up.
> I think this is same with https://lkml.org/lkml/2017/7/28/317 case.
> 
> The OOM killer does not wait for OOM victims until existing OOM victims release
> memory by calling exit_mmap(). The OOM killer selects next OOM victim as soon as
> the OOM reaper sets MMF_OOM_SKIP. As a result, when the OOM reaper failed to
> reclaim memory due to e.g. mlocked pages, the OOM killer immediately selects next
> OOM victim. But since 25391 and 25392 are consuming little memory (maybe these are
> already reaped OOM victims), neither 25391 nor 25392 was selected as next OOM victim.
> 

Yes, mlocked is troublesome. I have other incidents where crond and systemd-
udevd were killed by mistake, and it even tried to kill kworker/0.

https://cailca.github.io/files/dmesg.txt


