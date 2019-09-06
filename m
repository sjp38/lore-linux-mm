Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96DE7C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:48:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58C0F206B8
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:48:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="DMMI3JjX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58C0F206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0DEC6B0003; Fri,  6 Sep 2019 09:48:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBE446B0006; Fri,  6 Sep 2019 09:48:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CACA76B0007; Fri,  6 Sep 2019 09:48:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id AD5C16B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:48:35 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4CAE9824CA3D
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:48:35 +0000 (UTC)
X-FDA: 75904625790.23.cook03_6808246844529
X-HE-Tag: cook03_6808246844529
X-Filterd-Recvd-Size: 4207
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:48:34 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id i78so5624158qke.11
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 06:48:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=E6ClIVEVI/1JJKiq2EiFIPAxSwOdpsnxtYZsC7qvt+E=;
        b=DMMI3JjXaW2YLu2vPaGQtSIBahHlw00Y8rLKKN0U07K3mu6EhAtEiTIWq3hanv1zoy
         ctGZevq0xYgHve1Rv2V58fqSr69wFX/yyM9Qo0HbOwS+IULgFyiwnNkiM0rht1kXN4iN
         EBQML5zzOK3zURYlvlqaZJKLpZE2fDv8jiT2GR5buJtRGhAMAmX0whcddnADq6FB/CeE
         KTTJX5UpAo/D1IYG2Ai4v0Jh2OXIGWVTJpjdm8NNGKI227Y5B9Em09EIcpaFGHgcP4G7
         P5SJofafWlsfWLJTbq26lBN6FsPPynUQbbU5UeRPxQTkY9kAJi5IvUa2kC9luN+2sbuU
         Q6uw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=E6ClIVEVI/1JJKiq2EiFIPAxSwOdpsnxtYZsC7qvt+E=;
        b=G8WX4RWzAzNQH+VWCHy8mn4erBdRrI8OoXimSB5LP3xmuh7OI/zh+0l+fSs/KBZ0eg
         TZXJCB8uNCoiipcNRyJeDtDpT1fAC5tfilhNTh3S6eCzK4SyD8ri1HMw+6X1i9cOrRPd
         Vr7TnkQdTtCyUidn3+kiIFMD/wd4Yp4dKgQP/PMiPoH6Kc5elX8v0kXyJsPfbyUEfCHj
         +x7IFOABGHAJ+tKbv/S1LtRG9MhXIZHTR+jNsk3gZBzqOuntAm1YAC6eu9dFC6L2GZ/1
         YOjqx1Nj9dCvH4Yl838OEXcSWUfJElJLSa6pJElOhi1uQNkvqH1iOxntK39Iq4+0nD4Y
         e3Gw==
X-Gm-Message-State: APjAAAVRlRCbQzY2CMTCuOLmKAG29975CyNX8jLfDxBTmwgRKjmF/ZlG
	uZH99WaVh0V6uTom8EkiecfbVqZbMbc=
X-Google-Smtp-Source: APXvYqwczZaagfmC/gcLOahmQAZusbv8alzrtU+DSHOssD1x4lIvl2ZHoN+QTttIRqWWvhu8TXHdmA==
X-Received: by 2002:a37:c40a:: with SMTP id d10mr4965429qki.97.1567777714211;
        Fri, 06 Sep 2019 06:48:34 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id d45sm2982613qtc.70.2019.09.06.06.48.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 06:48:33 -0700 (PDT)
Message-ID: <1567777712.5576.111.camel@lca.pw>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
From: Qian Cai <cai@lca.pw>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>
Date: Fri, 06 Sep 2019 09:48:32 -0400
In-Reply-To: <7eada349-90d0-a12f-701c-adac3c395e3c@i-love.sakura.ne.jp>
References: <20190903144512.9374-1-mhocko@kernel.org>
	 <1567522966.5576.51.camel@lca.pw> <20190903151307.GZ14028@dhcp22.suse.cz>
	 <1567699853.5576.98.camel@lca.pw>
	 <8ea5da51-a1ac-4450-17d9-0ea7be346765@i-love.sakura.ne.jp>
	 <1567718475.5576.108.camel@lca.pw>
	 <192f2cb9-172e-06f4-d9e4-a58b5e167231@i-love.sakura.ne.jp>
	 <1567775335.5576.110.camel@lca.pw>
	 <7eada349-90d0-a12f-701c-adac3c395e3c@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-09-06 at 22:41 +0900, Tetsuo Handa wrote:
> On 2019/09/06 22:08, Qian Cai wrote:
> > Yes, mlocked is troublesome. I have other incidents where crond and systemd-
> > udevd were killed by mistake,
> 
> Yes. How to mitigate this regression is a controversial topic.
> Michal thinks that we should make mlocked pages reclaimable, but
> we haven't reached there. I think that we can monitor whether
> counters decay over time (with timeout), but Michal refuses any
> timeout based approach. We are deadlocked there.
> 
> >                               and it even tried to kill kworker/0.
> 
> No. The OOM killer never tries to kill kernel threads like kworker/0.

I meant,

[40040.401575] kworker/0:1 invoked oom-killer:
gfp_mask=0x40cc0(GFP_KERNEL|__GFP_COMP), order=2, oom_score_adj=0

> 
> > 
> > https://cailca.github.io/files/dmesg.txt
> 
> 

