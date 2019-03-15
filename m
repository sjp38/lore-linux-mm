Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CCA6C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 21:34:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B417206DF
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 21:34:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="fnb8QccZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B417206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9438D6B02C9; Fri, 15 Mar 2019 17:34:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 922896B02CA; Fri, 15 Mar 2019 17:34:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82EEA6B02CB; Fri, 15 Mar 2019 17:34:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55D0A6B02C9
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 17:34:24 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id i3so9928125qtc.7
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 14:34:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=kZVcwvAiuP5NbAXO+8otQq6PR1UUHjavABGz9JhZQ+Q=;
        b=dKJFZnWV0mQrTEk2F8Nllv6emoRnmg4dJD4OkdIPmVW5xEtQn0XwvG3G3oUcEErKyR
         ILftawGQ0Ul5iDofxDycw28GYUuPxqf2V9YzKdw77uVp02Zjlccw5U74lRW/BCNaCdGn
         RCHXW9OqzEe5iMoEdo8l3J22SYH8cmvuOA6DXlFGwab6HhezldEXHkaC6z3XM7Ckrp1q
         myH46tYBDSMjesCNBJF2yDIZK4nNgnM6jO+OZSspx8Sk2rXMUcUmdfUZCl4ZReZkXwWK
         jyDgTTbcny/9tt8/28saFt1wLTmT4KbA3RKz3zhcnd1j3zupSPQgBnor1RhlYtSM/Mcl
         H3Rw==
X-Gm-Message-State: APjAAAVLiHxtxjv5X56/NIMOppnr1OvIw6SbbRMIgjIyK+NKhlNWYPC0
	5ma3p8znwgWLa2TAtMz4/L/VWp4tuyUPY0GWWXYYgjfSgll1Z3Obe7Iuy5qF3ssFYMSNH2CpvhL
	houy7mclEgz0ymqrHPXtNXDbXRp92XHRtlK3WJiUHl1PoPh3O3DQuy750AC+kGVLUJg==
X-Received: by 2002:a0c:a485:: with SMTP id x5mr4197931qvx.206.1552685663902;
        Fri, 15 Mar 2019 14:34:23 -0700 (PDT)
X-Received: by 2002:a0c:a485:: with SMTP id x5mr4197877qvx.206.1552685662685;
        Fri, 15 Mar 2019 14:34:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552685662; cv=none;
        d=google.com; s=arc-20160816;
        b=mI9z4skrTxhEf84Kbntz0hWlgrqVs8WFO+K7hA+rNHkmbV7y86f3NIQUmGz6wQK/pu
         eReQwVOkcMo7XkrcVXOp7K3lhnLGcN8bXfvm2P1PN2kFeZEBJnoU2oamGvHX1agZ5AtD
         kndtLINdqtP2osg42FMeS1uLgFvjcfM4+7nPMm4WiMNHy6FKcVqggKNiz1m+en+Q90hN
         dpXA7b9HWyan609zwks5njETYWgq8EMI8uqSq2jRYDirgTC/FaQXseAb/7l+296qQ+uD
         gQmQhPl48nwoU/gQtfT7UtathnGfV0YjeiEYeTptFowRQz4dIoGWZ6HW3NXt6Uw2tUdn
         hbvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=kZVcwvAiuP5NbAXO+8otQq6PR1UUHjavABGz9JhZQ+Q=;
        b=pvrPouWfwt4lrNGxzizzNXuc5xHcrI2AgZwtPpAOrdqCSLiKeTIOHdXwPGLsoFbnW5
         Bv6UhRZkBXv0p6pOI/DmXxVJiktEk0hIcCA8WY7GFEVlfSouSINZm7UqLAbZMH1i5RZw
         h8T87H0QDPKxmmE4Qp8yMusdP0RlVNn2K6EaCBEmqrctmeCYzIPKj0uJJZmuUms+GxGi
         e3Gbsy4s/1ZfeFP53+frqLVYpkLeyj07Z9EN/8KZbQteVMOnAB6HgX1P6Vamlqj82+wP
         8iYX2Q3gQeOvmAxdGA4iTKjC3UXqULFT7MspOG75D7HmQR8gnSq9rntvY8ItbHUmOaOJ
         DKww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fnb8QccZ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w20sor2844838qtn.46.2019.03.15.14.34.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 14:34:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fnb8QccZ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kZVcwvAiuP5NbAXO+8otQq6PR1UUHjavABGz9JhZQ+Q=;
        b=fnb8QccZ91NMe+mEY1W/a7C5EToIwhFmfZZl100rVIrxaSrX1d8Powes9KMsPkcmCa
         BEb3nD2/pVPvPtpqh/w1V8oUAn5P5yvxIGbviAbAERnNt6MqtBqpG2Pie77DVOolo9bc
         BKKgHWUf4Skbp1b5lR6yLITewQJNcsA5eJe753EYHKpriN2CrGcP+arrGS1ss8S1WN0y
         VDXinZ3BVmNlqQTZIqcjC8oFUhdBkcy4aRzTssMKVRP0i1wze/LVi8CUEI0Q7B8u0OjV
         Jaz3eznDjAVI/Z6fRgrdn/jU7Bit2MYJahBySXDBWJAhQx5Su9+xkF1sb6AsqcyIgpJS
         UqKA==
X-Google-Smtp-Source: APXvYqzGiDRKrRGonijEmawyAbfyIR3ZQLdfwrTYV4Ya0ee3MZn0pQvXNFGAlQvK3A7SJuUkd68wSg==
X-Received: by 2002:ac8:5295:: with SMTP id s21mr4630664qtn.322.1552685662295;
        Fri, 15 Mar 2019 14:34:22 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id e22sm2202530qte.42.2019.03.15.14.34.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 14:34:21 -0700 (PDT)
Message-ID: <1552685660.26196.3.camel@lca.pw>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
From: Qian Cai <cai@lca.pw>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, Mikhail Gavrilov
	 <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org, mgorman@techsingularity.net, vbabka@suse.cz
Date: Fri, 15 Mar 2019 17:34:20 -0400
In-Reply-To: <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
References: 
	<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
	 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-03-15 at 16:58 -0400, Daniel Jordan wrote:
> On Tue, Mar 12, 2019 at 10:55:27PM +0500, Mikhail Gavrilov wrote:
> > Hi folks.
> > I am observed kernel panic after updated to git commit 610cd4eadec4.
> > I am did not make git bisect because this crashes occurs spontaneously
> > and I not have exactly instruction how reproduce it.
> > 
> > Hope backtrace below could help understand how fix it:
> > 
> > page:ffffef46607ce000 is uninitialized and poisoned
> > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > ------------[ cut here ]------------
> > kernel BUG at include/linux/mm.h:1020!
> > invalid opcode: 0000 [#1] SMP NOPTI
> > CPU: 1 PID: 118 Comm: kswapd0 Tainted: G         C
> > 5.1.0-0.rc0.git4.1.fc31.x86_64 #1
> > Hardware name: System manufacturer System Product Name/ROG STRIX
> > X470-I GAMING, BIOS 1201 12/07/2018
> > RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
> 
> This is new code, from e332f741a8dd1 ("mm, compaction: be selective about what
> pageblocks to clear skip hints"), so I added some folks.
> 
> Can you show
> $LINUX/scripts/faddr2line path/to/vmlinux __reset_isolation_pfn+0x244
> ?

Yes, looks like another instance of page flag corruption. I have been chasing
this thing for a while.

https://lore.kernel.org/linux-mm/604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw/

Basically, linux-next is easier to reproduce than the mainline.

LTP oom* tests and stress-ng has been useful to reproduce so far.

# stress-ng --sequential 64 --class vm −−aggressive -t 60 --times

I did manage to reproduce the memory corruption in arm64 on the mainline too
(originally only x64). Still that BUG_ON(!PageBuddy(page)).

[51720.012258] kernel BUG at mm/page_alloc.c:3124!
[51720.040287] CPU: 194 PID: 1311 Comm: kcompactd1 Kdump: loaded Tainted:
G        W    L    5.0.0+ #13
[51720.049411] Hardware name: HPE Apollo 70             /C01_APACHE_MB         ,
BIOS L50_5.13_1.0.6 07/10/2018
[51720.059232] pstate: 90400089 (NzcV daIf +PAN -UAO)
[51720.064038] pc : __isolate_free_page+0x7bc/0x804
[51720.068659] lr : compaction_alloc+0x948/0x2490
[51720.073094] sp : edff8009836576c0
[51720.076400] x29: edff800983657740 x28: efff100000000000 
[51720.081705] x27: ffff80977c3b8f10 x26: 0000000000000009 
[51720.087010] x25: ffff80977c3b90b8 x24: ffff80977c3b8f20 
[51720.092314] x23: 0000000000000800 x22: ffff80977c3b8f40 
[51720.097619] x21: 00000000000000ff x20: 00000000000000ff 
[51720.102923] x19: ffff80977c3b8f10 x18: efff100000000000 
[51720.108227] x17: ffff1000115c02b8 x16: 0000000000918000 
[51720.113532] x15: 0000000000912000 x14: efff100000000000 
[51720.118838] x13: 00000000000000ff x12: 00000000000000ff 
[51720.124141] x11: 00000000000000ff x10: 00000000000000ff 
[51720.129447] x9 : 00000000f0000000 x8 : 0000000070000000 
[51720.134753] x7 : 0000000000000000 x6 : ffff1000105f5620 
[51720.140058] x5 : 0000000000000000 x4 : 0000000000000080 
[51720.145364] x3 : ffff80977c3b90c0 x2 : 0000000000000000 
[51720.150669] x1 : 0000000000000009 x0 : ffff1000132fe200 
[51720.155976] Process kcompactd1 (pid: 1311, stack limit = 0x00000000c41b1162)
[51720.163015] Call trace:
[51720.165457]  __isolate_free_page+0x7bc/0x804
[51720.169721]  compaction_alloc+0x948/0x2490
[51720.173821]  unmap_and_move+0xdc/0x1dbc
[51720.177649]  migrate_pages+0x274/0x1310
[51720.181476]  compact_zone+0x26f8/0x43c8
[51720.185304]  kcompactd+0x15b8/0x1a24
[51720.188874]  kthread+0x374/0x390
[51720.192100]  ret_from_fork+0x10/0x18
[51720.195669] Code: 94176b90 17fffebb d0016e20 91080000 (d4210000)

