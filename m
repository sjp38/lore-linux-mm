Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D40FC43387
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 13:24:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 293FB20663
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 13:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MK+m7w1f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 293FB20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 668A78E013F; Sun,  6 Jan 2019 08:24:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6182B8E0001; Sun,  6 Jan 2019 08:24:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52E888E013F; Sun,  6 Jan 2019 08:24:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5F38E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 08:24:36 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id p4so45616769iod.17
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 05:24:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=A94FPMFmRCu34mADbdoh8iPEP0sj3Yw4xbl5b2Pzpt8=;
        b=Dtt6FT/14ejLBfhNZueXJ+UjV7vZzBcGte94m2eyDJRM7cAnfbG/KDNMk5ug8vB2/3
         cyyFj5Cc3SdpJ2kNogBDTzZciG4SaZkUcOd/J5RTTtCe0k04Fw99231W14YMLIDJMoBa
         do0FdHx9CwYJ6y1ZJ5zMG3teslmi842QSYQDANfSEGCc+wnIO2Jd3gVfMCOj6P+oarB9
         PKZEpyiBjSOhRQ5bmhDRmEhR9nwDa6y2jYlPW645ZbO8lFSimr7imTnIamBRCu4HtZ/U
         p3R7oRyjMvc95cpzTFZ6MVNY1RmhvotMsSMHwl9jcCZPdgWfpB3s2bCzxIdJSLLyQ4hf
         Alug==
X-Gm-Message-State: AA+aEWadMh/m0BjTV/RCDqBXv5FmWrvNVrNpMHlMC+0BfbNO1ae6R0nu
	WJNDmlhePcXBFi+P3RWqFUSVDIJOKv3rhkUNIaQK6vs4fMy+ZuZfPf2fOM7aNoqe9UyU0rc/agS
	gDDJbGI2D7+G0X7zk7EV8aPL5EE+NU060dHj2TbdFu3uK/bJmI64qtumkcF+aRkeQR6GJxldrbE
	PEPCZHY1S/mXCm6o4eFb0JHRqzndDEoPVr95lcm3n/E79eGbXwDk59BRQaIVJww+0u61hXwMilw
	ZkSYNYcfy/92urinmvtcMvD0C7lj9ahYEBzkvWBqJ7co+jKOPXDE1Qd1SBIqATaXtz/Z5uA4XxM
	sjVKV9MtPQQPQFqN3IBc+BOg97XcPgD1MWZLgXMcTY4dGAIhfX9HADgDmaq3nU78f9oZfm//pa8
	F
X-Received: by 2002:a02:b4d1:: with SMTP id a17mr40572804jak.27.1546781075922;
        Sun, 06 Jan 2019 05:24:35 -0800 (PST)
X-Received: by 2002:a02:b4d1:: with SMTP id a17mr40572783jak.27.1546781074979;
        Sun, 06 Jan 2019 05:24:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546781074; cv=none;
        d=google.com; s=arc-20160816;
        b=BJpOUKfUWjqZf0+nrIjw+GOF/Li1z1uE9v5KnP5C1IFKXl1l0JlR7DsgRhBXW4Y4K+
         cHDHQcnqq3B21wosCZKtBRGNG4rUza8Xd234wIXn3MRTOr+R/19UBOjAxDqmBrtQxSJE
         0VyaXxRLuoxYnwJwS3RGoSoT52XihzErJtNSBdS/9FqL7YymJA44nD51jwIIQP0RteZD
         B4FSUUrGbK1WSPzlFikuwiy20Ls7pn973PF2oMW9C+W4k0AtGlJj5T/cDmMiob6bYe+x
         DE5nxAkU8gzHVuuW6nz1rzeNUXj7rNCBnE2K9lp+o4WkG4vTy9a1kSIrEn0ScWmb+x2n
         JfTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=A94FPMFmRCu34mADbdoh8iPEP0sj3Yw4xbl5b2Pzpt8=;
        b=PnbFEc2D46nC7kL+OiPExTcUNTpAsjFO15YAzGjvYvkpshEEfxt6tse0oRXNXGMCAI
         7l8+ZYOZhdnVF8+5vx/FhLwakwnL4QMn1/PvXaGhsPSYvH9EdyPhWQKQGHZbueCBg91X
         BG/ukpIhZcO1pDd4rVyHirbQPN7kl5NCaVYnqkk7EElJ6C3HiYSgFpeTOBWWE/uSGa35
         6mys8rCYb4egPEziJ3avqvsN5f6AETfukkItzmssX3O0yHR/f3sDtEaOvH/WIHQXtK9M
         Dh7ReFAh9c//U5oZE+9Y7J5gPqeMBBSn2uQcAKuhNrUI+23ZfQznwK3eGRuw2W0ocpc/
         LLNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MK+m7w1f;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o185sor9570281ito.8.2019.01.06.05.24.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 05:24:34 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MK+m7w1f;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=A94FPMFmRCu34mADbdoh8iPEP0sj3Yw4xbl5b2Pzpt8=;
        b=MK+m7w1ftHUz4uzw6nibC38wTZ3HmdrCwFfq1n+Uz5n80s5SoomwCpHce3AhkAQaHt
         sfe3TsWB7DxlXxvh8Pt14lrqsPZAFa7roYBnd0XeKNseRo3cmuYfvtgwpKCo/rD7Luah
         29gri9qDksgZWH/co8X4/+kv4aHsu3eaemQy9WZvEmJd/cQlUIrrLKlO/K8zH1p5t0YM
         OnrGNgu7KjYM/iXuaO8KUSvGwa0vS6uiG8BpEA3WTNvm2H6QU/MdjMaHFsJVuUZkhx9v
         VYt88mgP2I6yIawysVo4z2IIhCgAj+fvwrYLP5V/HrMNW7bVd1NzqCYQzhdxaIgJRiXV
         G3YA==
X-Google-Smtp-Source: ALg8bN6JdQi0jEz8r5GHyCJfoQpsXYffmxwDe5Z++UDHkQR+iNNc4bjjg8mcrIi//WD4TVaottwtiKWu5D4PHJctsfw=
X-Received: by 2002:a24:f14d:: with SMTP id q13mr4793104iti.166.1546781074476;
 Sun, 06 Jan 2019 05:24:34 -0800 (PST)
MIME-Version: 1.0
References: <0000000000007beca9057e4c8c14@google.com> <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
 <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp> <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
In-Reply-To: <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 6 Jan 2019 14:24:23 +0100
Message-ID:
 <CACT4Y+Y5cdD=optF2k4a0W7vriVnzmzLU0SPGEJoOHRMi_bsZA@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, 
	David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, 
	LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106132423.ZCyz7FAhcHdoqi8mVdQWDRFPx6VGJlDm8wpZcKEYcNs@z>

On Sat, Jan 5, 2019 at 11:49 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/03 2:06, Tetsuo Handa wrote:
> > On 2018/12/31 17:24, Dmitry Vyukov wrote:
> >>>> Since this involves OOMs and looks like a one-off induced memory corruption:
> >>>>
> >>>> #syz dup: kernel panic: corrupted stack end in wb_workfn
> >>>>
> >>>
> >>> Why?
> >>>
> >>> RCU stall in this case is likely to be latency caused by flooding of printk().
> >>
> >> Just a hypothesis. OOMs lead to arbitrary memory corruptions, so can
> >> cause stalls as well. But can be what you said too. I just thought
> >> that cleaner dashboard is more useful than a large assorted pile of
> >> crashes. If you think it's actionable in some way, feel free to undup.
> >>
> >
> > We don't know why bpf tree is hitting this problem.
> > Let's continue monitoring this problem.
> >
> > #syz undup
> >
>
> A report at 2019/01/05 10:08 from "no output from test machine (2)"
> ( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
> says that there are flood of memory allocation failure messages.
> Since continuous memory allocation failure messages itself is not
> recognized as a crash, we might be misunderstanding that this problem
> is not occurring recently. It will be nice if we can run testcases
> which are executed on bpf-next tree.

What exactly do you mean by running test cases on bpf-next tree?
syzbot tests bpf-next, so it executes lots of test cases on that tree.
One can also ask for patch testing on bpf-next tree to test a specific
test case.

