Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23196C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:58:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE4FA20679
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:58:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="UCwvLTFa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE4FA20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 669AD6B0005; Mon, 24 Jun 2019 08:58:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61A698E0003; Mon, 24 Jun 2019 08:58:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E28C8E0002; Mon, 24 Jun 2019 08:58:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 316D46B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:58:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id v58so16950570qta.2
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:58:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Xx/RWmPWBvyJH2ZU2NlE1zPXjYqIgHNE0+DzqPjHLoo=;
        b=hxiU+mM3sOcNx73NQlWpVhAj1jPYzpF731aRaiuOPoCfR5/Rb5fMb8dIh2XdFbN3e6
         tsL3STXNLYjVJV4Nh/Re6SFBCcHjOY5sHZwQNUfZZkvKblJPjMdwRLtC3etqJ3jbH2q0
         bFlAMxOXQu4yRO2+DKqwh/10A2R7KfzGyd12P5uY0DMoMQLiOjFZORcXyOyZmHWcsmLN
         zwWuq7ao25TkXoGYYJlSu6+LeVlVmlIlTENNOHKOEPlFFJ4Ius4dgnwgYpD6YjTgP6yC
         6vD8PACjcqjbvszHbBREcJKishmbxbHv+wznQn/ZO75j0R/AlteRZEO4RTS7cT51sxsY
         whHQ==
X-Gm-Message-State: APjAAAVkQwqEn1gVojTVLR7KcZUl32TcB5xx7AcLTEGZFPnsPvXzKSEm
	kCsfUgnLXjfPTBzb6DbAwHZe/A97XaPqYDazrxhDjKguvWnFfEPscqdcfHz4S1Qfph/1XAU6vEO
	r9J8MPXExavCCf0Grr5JNM3X07FUdeMTl1TUyAxlCxLJGmfdkVM5L/VWpcLzOHW6Nng==
X-Received: by 2002:a37:6795:: with SMTP id b143mr15375545qkc.387.1561381132867;
        Mon, 24 Jun 2019 05:58:52 -0700 (PDT)
X-Received: by 2002:a37:6795:: with SMTP id b143mr15375498qkc.387.1561381132092;
        Mon, 24 Jun 2019 05:58:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381132; cv=none;
        d=google.com; s=arc-20160816;
        b=QyaZR54ZmLiYN4GDRN7vYYhkOPX/ElpAenm0Ur6kgniKQL3utjFTE0msREyHeTOgNL
         033Tkdlg1Llu+D6vsghs5IKOBXmkvwq0/KMLqbPsFe3cdyv/DdMTgu1NaOsYH0YYpic1
         RTgkm9FXOVhE+3dKi/5LC3u6iKtYPVw/pcZx2FkXw6ObCckuDmiDDS4aWSJFrfMFInOs
         MHooAgxki0TLbEDBFzcxtZzaiRSxjPbMzTAcngnC9OLC42m79zCRbUHVwEqnYxAYDTeb
         UML1Coxoi7YIuSSNkFa0LmbxCv20/Ngse3r9XrbX9GuszaucGLt6jXarqCmaBYI211yA
         9c7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=Xx/RWmPWBvyJH2ZU2NlE1zPXjYqIgHNE0+DzqPjHLoo=;
        b=0wp5nb00PYaNon/8yTtdUUNHi+YSuqgx6BH6hcaEdDjLIfw4XzN3W71xtGR0PDZT2f
         4eNgC1I99bXfl4i0vgg7EEgSKaQMG+Sl6KtK55bhhQSMoDkg+aR/pYkWnVEyo1hCWjHT
         6ybaXoRQ15TrjCYfcJPs6Cr0d9043o+pM6RkWBusur8kZTOTwMxUKQ313L84+WtcjeG0
         ulTiJkhnHj2zmwI2XbpZq00FQ0Xgt8FZmV33DB83GV7Rmcx65IgD149nhjGJHUo9Z3qB
         WajkO/dsVjHsbAuAlFWXy7Ck+2DLpyTQ6tVUyB6qb9vcKGffGs6fPM+KwnoIyG7MhiOl
         Dvlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=UCwvLTFa;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f69sor6129471qke.60.2019.06.24.05.58.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 05:58:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=UCwvLTFa;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Xx/RWmPWBvyJH2ZU2NlE1zPXjYqIgHNE0+DzqPjHLoo=;
        b=UCwvLTFauBZM95y94QPC9oGAEFrPbOt1jJVDGyUlhejwVII3S37uAzEACDd2yNiWBO
         ZfugWza9SALwHGlXK6Us5p0JFr8g7Uq6jOhsgHGnOv2iLSTaBMMCmFeIlJ/PlMYSoVKY
         7V1p9+PFLFuZxBSv/8oozyk+2ws3ohRQ+lP5KlRHZzB0zyaRdMRtH6GzM0Ybc9IdSt7C
         QYW+6878VyjokxvbhFe/IuwqXjgMMKC4JR2xtAJTacgmn59f49lg93ukqIFU0Wx62B2w
         TrRRXepBonyL+njzjSwQU4tq5njBfTcRcrIsKEVqtWoohLqcA+kGcBYNBJF6vy8F4jB4
         LywQ==
X-Google-Smtp-Source: APXvYqxjWNfQxLfoP+rpGNMOujJkBpLhTS8ucR6j2FpSxRJn0uwMDXTszglfdGdwE/0XbXCQipp1Kw==
X-Received: by 2002:a37:6b07:: with SMTP id g7mr20623988qkc.217.1561381131743;
        Mon, 24 Jun 2019 05:58:51 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id f1sm5502266qke.117.2019.06.24.05.58.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 05:58:50 -0700 (PDT)
Message-ID: <1561381129.5154.55.camel@lca.pw>
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
From: Qian Cai <cai@lca.pw>
To: Will Deacon <will@kernel.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Will Deacon
	 <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	"linux-mm@kvack.org"
	 <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org
Date: Mon, 24 Jun 2019 08:58:49 -0400
In-Reply-To: <20190624093507.6m2quduiacuot3ne@willie-the-truck>
References: <1560461641.5154.19.camel@lca.pw>
	 <20190614102017.GC10659@fuggles.cambridge.arm.com>
	 <1560514539.5154.20.camel@lca.pw>
	 <054b6532-a867-ec7c-0a72-6a58d4b2723e@arm.com>
	 <EC704BC3-62FF-4DCE-8127-40279ED50D65@lca.pw>
	 <20190624093507.6m2quduiacuot3ne@willie-the-truck>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-24 at 10:35 +0100, Will Deacon wrote:
> Hi Qian Cai,
> 
> On Sun, Jun 16, 2019 at 09:41:09PM -0400, Qian Cai wrote:
> > > On Jun 16, 2019, at 9:32 PM, Anshuman Khandual <anshuman.khandual@arm.com>
> > > wrote:
> > > On 06/14/2019 05:45 PM, Qian Cai wrote:
> > > > On Fri, 2019-06-14 at 11:20 +0100, Will Deacon wrote:
> > > > > On Thu, Jun 13, 2019 at 05:34:01PM -0400, Qian Cai wrote:
> > > > > > LTP hugemmap05 test case [1] could not exit itself properly and then
> > > > > > degrade
> > > > > > the
> > > > > > system performance on arm64 with linux-next (next-20190613). The
> > > > > > bisection
> > > > > > so
> > > > > > far indicates,
> > > > > > 
> > > > > > BAD:  30bafbc357f1 Merge remote-tracking branch 'arm64/for-
> > > > > > next/core'
> > > > > > GOOD: 0c3d124a3043 Merge remote-tracking branch 'arm64-fixes/for-
> > > > > > next/fixes'
> > > > > 
> > > > > Did you finish the bisection in the end? Also, what config are you
> > > > > using
> > > > > (you usually have something fairly esoteric ;)?
> > > > 
> > > > No, it is still running.
> > > > 
> > > > https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
> > > > 
> > > 
> > > Were you able to bisect the problem till a particular commit ?
> > 
> > Not yet, it turned out the test case needs to run a few times (usually
> > within 5) to reproduce, so the previous bisection was totally wrong where
> > it assume the bad commit will fail every time. Once reproduced, the test
> > case becomes unkillable stuck in the D state.
> > 
> > I am still in the middle of running a new round of bisection. The current
> > progress is,
> > 
> > 35c99ffa20ed GOOD (survived 20 times)
> > def0fdae813d BAD
> 
> Just wondering if you got anywhere with this? We've failed to reproduce the
> problem locally.

Unfortunately, I have not had a chance to dig this up yet. The progress I had so
far is,

The issue was there for a long time goes back to 4.20 and probably earlier. It
is not failing every time. The script below could reproduce it usually within 10
0 tires.

i=0; while :; do ./hugemmap05 -m -s; echo $((i++)); sleep 5; done

This can be reproduced in an error path, i.e., shmget() in the test case will
fail every time before triggering the soft lockups.

# ./hugemmap05 -s -m
tst_test.c:1112: INFO: Timeout per run is 0h 05m 00s
hugemmap05.c:235: INFO: original nr_hugepages is 0
hugemmap05.c:248: INFO: original nr_overcommit_hugepages is 0
tst_safe_sysv_ipc.c:111: BROK: hugemmap05.c:97: shmget(218366029, 103079215104,
b80) failed: ENOMEM
hugemmap05.c:192: INFO: restore nr_hugepages to 0.
hugemmap05.c:201: INFO: restore nr_overcommit_hugepages to 0.

Summary:
passed   0
failed   0
skipped  0
warnings 0
0

My understanding is that the soft lockups are triggered in this path,

ipcget
  ipcget_public
    ops->getnew
      newseg
        hugetlb_file_setup <- return ENOMEM

[ 1521.471216][ T1309] INFO: task hugemmap05:4718 blocked for more than 860
seconds.
[ 1521.478731][ T1309]       Tainted: G        W         5.2.0-rc4+ #8
[ 1521.485023][ T1309] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 1521.493568][ T1309] hugemmap05      D27168  4718      1 0x00000001
[ 1521.499815][ T1309] Call trace:
[ 1521.502985][ T1309]  __switch_to+0x2e0/0x37c
[ 1521.507278][ T1309]  __schedule+0xa0c/0xd9c
[ 1521.511484][ T1309]  schedule+0x60/0x168
[ 1521.515430][ T1309]  __rwsem_down_write_failed_common+0x484/0x7b8
[ 1521.521546][ T1309]  rwsem_down_write_failed+0x20/0x2c
[ 1521.526717][ T1309]  down_write+0xa0/0xa4
[ 1521.530747][ T1309]  ipcget+0x74/0x414
[ 1521.534518][ T1309]  ksys_shmget+0x90/0xc4
[ 1521.538638][ T1309]  __arm64_sys_shmget+0x54/0x88
[ 1521.543366][ T1309]  el0_svc_handler+0x198/0x260
[ 1521.548005][ T1309]  el0_svc+0x8/0xc
[ 1521.551605][ T1309] 
[ 1521.551605][ T1309] Showing all locks held in the system:
[ 1521.559349][ T1309] 1 lock held by khungtaskd/1309:
[ 1521.564251][ T1309]  #0: 00000000033dd0e2 (rcu_read_lock){....}, at:
rcu_lock_acquire+0x8/0x38
[ 1521.573014][ T1309] 2 locks held by hugemmap05/4694:
[ 1521.578010][ T1309] 1 lock held by hugemmap05/4718:
[ 1521.582904][ T1309]  #0: 00000000c62a3d44 (&ids->rwsem){....}, at:
ipcget+0x74/0x414
[ 1521.590707][ T1309] 1 lock held by hugemmap05/4755:
[ 1521.595595][ T1309]  #0: 00000000c62a3d44 (&ids->rwsem){....}, at:
ipcget+0x74/0x414
[ 1521.603373][ T1309] 1 lock held by hugemmap05/4781:
[ 1521.608270][ T1309]  #0: 00000000c62a3d44 (&ids->rwsem){....}, at:
ipcget+0x74/0x414

