Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57781C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:24:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F47E218D4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QGJNkRZs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F47E218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DA856B0003; Tue, 23 Jul 2019 17:24:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98AD16B0005; Tue, 23 Jul 2019 17:24:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 878778E0002; Tue, 23 Jul 2019 17:24:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68E9D6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:24:52 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id k21so48648858ioj.3
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:24:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=M6w3AQT/kAXXnbql10OE6lR9hDAhCRnli8EPorWLJVk=;
        b=gnpSqHjF+GyP2fOwlrhvjfiJHvhFBJiZzCJURyvax4uxisG8Pn3TKibRMxoLtHnPmR
         +BzmsKVT4o2rT8s2J2KZL+pdglwlb25StoIOL4ZTajymclJlSrI/d3rH8H17j8207c8u
         XaoKXYo68r2Z3iNNXTwg/7XDeb4vS3bH6LZoxj72qAFlAFfjFCUWhEQ1fINKQJm8N2yN
         cJMbojp+Tlej1qjq4LEDhibsUkssjf/zO4hSVk/hwLe6LAQMp6BngNbXUB1O/r+bK7Al
         krXWDVmxciKq1wRj8tuTRZua+0r3cBbrodcNvrqVIBBv5GGTAv+J0zIEWuSCCmuZ3UBa
         YEWw==
X-Gm-Message-State: APjAAAXh1qxceWGW4bLWG1EZB31d/mBwolbnC2IMdGWmtMvgRT+Q+A8S
	XClD/lZh2p6z5UNuryYGMmn+l5gtXCGnStIPG653W6qyVTnrlQHANYSYeZBf6YciEOVpRQj9obX
	4uUiqNQBrRsZW16RFbpgE6nGxddr5aM/cS+c3ScUsKfV4ue1zV5OUx4J+rMfpsujMWg==
X-Received: by 2002:a02:bb08:: with SMTP id y8mr36785353jan.51.1563917092100;
        Tue, 23 Jul 2019 14:24:52 -0700 (PDT)
X-Received: by 2002:a02:bb08:: with SMTP id y8mr36785322jan.51.1563917091403;
        Tue, 23 Jul 2019 14:24:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563917091; cv=none;
        d=google.com; s=arc-20160816;
        b=NLIYxqoZ1xyyGPlL3465fmUj/DGREZp48s94D/Kd9DRIiD8qXxqnW8KNC2nB5fMz+u
         JnbCMoFb2hTzDVev8z1TLKABO+fs21b0bGtVQi5D0ytRf2HxrMZg6X8pOTyRlpRR1R+e
         +3syTfVpD/fMse/QtkHMzVAyvbt+HPFKaRxFFahrDuzOWRad7C5qdwPVZYJm/B2MY76h
         Ijs6J5Xru3r6azciypOVLn7LfubPIpnEG+EeAPaE6whYq/X9NXGJ9p64YIIoZlqmQkPx
         V7zLLS5vZ1J4Gm3EImmfXYBcduoKdY0LtfE13yokqbMowPy/soCgcRrl5HRsHrCBg/uo
         JkXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=M6w3AQT/kAXXnbql10OE6lR9hDAhCRnli8EPorWLJVk=;
        b=QIbboc11OoWb6uBoxAwvdSJmKzIpcXlnTPH12Juf6WR83YXSGSFh8gUIfxAM0JARUT
         g0tCqxobbEfU0KgsgT/b4cymEekDfqwENbk2karn3XdrSXyRdhiCIQAHYKzq8+rY35xM
         uSVZBCj7QH3jvn1bffX2oml2JRiGKA27dmUl34CL41Cwu8HAB5JcGtNfvEFt2TEo3fVO
         wE4Q1Ns9rkK2xz+HUfjXaH0xoxipn2ctK7tVsp2UvGiTPDe0omuqx/HUvKmoqu4IDWA1
         gcBnAKsRFpRQr8N7NvZFDAJuipdm+8kSHNdoOx4Hz8rvt+TAu61StSsaRdZT9Xzrou8S
         M4Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QGJNkRZs;
       spf=pass (google.com: domain of koct9i@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=koct9i@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3sor105773238jam.9.2019.07.23.14.24.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 14:24:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of koct9i@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QGJNkRZs;
       spf=pass (google.com: domain of koct9i@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=koct9i@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=M6w3AQT/kAXXnbql10OE6lR9hDAhCRnli8EPorWLJVk=;
        b=QGJNkRZsxv5Zuf3BgPCZSqKQFZGj+62TufloKtPG2MZHXVGH1Gd0Lp6K2ETJIbCSjh
         9H8asFqfqbKMBBxMrqWl9WTuBXgxsHM7Hvujxd7Mwzg0TCSP+fQqr1kIT1Sb984JAHC3
         KFRtHdL8Nomx/M8Jrwx69IAiJJZKW1vawnwm6x6dcOqS/ZUdTMSZsXPw0d+5Z9j5hIlq
         rVAmZv0JRn+cBmfh4L4vnMcFIHHYgRJg/C2jixIYFE5ZqVpGxI5UgWCGqmddrraX8EbC
         V9YLC2jwBhDTpcvB8SfLT3PTMul+gIi/+9fKTr0YhWbOURJVhIsrLU0TaeW1+B7rgdxl
         DK5Q==
X-Google-Smtp-Source: APXvYqxKr4HupaYHi34Ne4j7ZwGE2Zn3T5z4Jpb3W+1WmUklRBx1IuSc0txOT2Cv/XB1evJIt72QfM/euePyWkorYTY=
X-Received: by 2002:a05:6638:cf:: with SMTP id w15mr3101134jao.136.1563917090945;
 Tue, 23 Jul 2019 14:24:50 -0700 (PDT)
MIME-Version: 1.0
References: <156388617236.3608.2194886130557491278.stgit@buzz> <20190723130729.522976a1f075d748fc946ff6@linux-foundation.org>
In-Reply-To: <20190723130729.522976a1f075d748fc946ff6@linux-foundation.org>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 24 Jul 2019 00:24:41 +0300
Message-ID: <CALYGNiMw_9MKxfCxq9QsXi3PbwQMwKmLufQqUnhYdt8C+sR2rA@mail.gmail.com>
Subject: Re: [PATCH] mm/backing-dev: show state of all bdi_writeback in debugfs
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Cgroups <cgroups@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 11:07 PM Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Tue, 23 Jul 2019 15:49:32 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
>
> > Currently /sys/kernel/debug/bdi/$maj:$min/stats shows only root bdi wb.
> > With CONFIG_CGROUP_WRITEBACK=y there is one for each memory cgroup.
> >
> > This patch shows here state of each bdi_writeback in form:
> >
> > <global state>
> >
> > Id: 1
> > Cgroup: /
> > <root wb state>
> >
> > Id: xxx
> > Cgroup: /path
> > <cgroup wb state>
> >
> > Id: yyy
> > Cgroup: /path2
> > <cgroup wb state>
>
> Why is this considered useful?  What are the use cases.  ie, why should
> we add this to Linux?
>
> > mm/backing-dev.c |  106 +++++++++++++++++++++++++++++++++++++++++++++++-------
> > 1 file changed, 93 insertions(+), 13 deletions(-)
>
> No documentation because it's debugfs, right?
>
> I'm struggling to understand why this is a good thing :(.  If it's
> there and people use it then we should document it for them.  If it's
> there and people don't use it then we should delete the code.
>

Well. Cgroup writeback has huge internal state:
bdi_writeback for each pair (bdi, memory cgroup ) which refers to some
blkio cgroup.
Each of them has writeback rate estimation, bunch of counters for
pages and flows and so on.
All this rich state almost completely hidden and gives no clue when
something goes wrong.
Debugging such dynamic structure with gdb is a pain.

Also all these features are artificially tied with cgroup2 interface
so almost nobody use them right now.

This patch extends legacy debug manhole to expose bit of actual state.
Alternative is exactly removing this debugfs file.

I'm using this debugfs interface for croups and find it very useful:
https://lore.kernel.org/patchwork/patch/973846/
but writeback has another dimension so needs own interface.

