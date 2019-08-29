Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F1C7C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 18:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C34FE21726
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 18:44:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="dl9qohKF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C34FE21726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 264856B0008; Thu, 29 Aug 2019 14:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 214956B000C; Thu, 29 Aug 2019 14:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 104536B000D; Thu, 29 Aug 2019 14:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id E15176B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 14:44:05 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 96537181AC9B4
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 18:44:05 +0000 (UTC)
X-FDA: 75876340050.10.lock95_23a9844495f17
X-HE-Tag: lock95_23a9844495f17
X-Filterd-Recvd-Size: 6194
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 18:44:04 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id i78so2439223qke.11
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:44:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QDRi/Xd9XfnkQ5sOxj7EVRPPb6YjOhNvBvKil4zJw/0=;
        b=dl9qohKF185MJTvsc/xIx5y2bsPkyUgeQyPr5ffE0hZoRxnas8wTSWNEjE47IMjSQt
         ClxH/8EVTw9Ka+9M0wwX+9B/tIxd5c9tbC4bJVP6ZwyImFCUqm28A7X+yPLCqQJFBBAV
         3DR877YtrSKP77RLHhkN9aaVXjjdSnAuMQixQQV6IvlbzoGtwvQjTLJTjwZMLpdTQDgx
         ewvCMg70knxrpix/UuQ1dzA8dmHi5pooHb91SW/yA0O3o0XTnVkP1+7DUQVBU/n2yWRZ
         YvrEv8swmwRvi3EEp2XB0vErOGppjRla558g1r6lB4UaSNmoXh8pnI+WpxL6iTq7jsfA
         L4Hg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=QDRi/Xd9XfnkQ5sOxj7EVRPPb6YjOhNvBvKil4zJw/0=;
        b=o5lZi6p6Yf87H8qshU86zIP26SduXEcQtpsiwNmB7m0MbeKKTwyOMynnk63uKJ99K7
         1we1vLqVz8ZnxCO0E283fZBzPNakv9mob0EiJpSZ4gxckyXu/lau9OC7TZW+3GbbF5A2
         SM9z9JksgjrGR60G+SuMiO0Yd2mfHbu8XofYBbtLBpbhUYLjpWBbsFb9oPtVxX3R9AcN
         D7yrIURdd1TBIVisJs8vJIAYX5gf4Q95mn4fX7j5pi37WnzaRhwmqzfYVcynBZUk/W+A
         WzLMz0og1lJ+sDTYKftpq+amWlK14tbDUsgT9GuudyvprUkCgq4Dk5Hoyi+UdvLVhgbp
         WDjw==
X-Gm-Message-State: APjAAAU+hLzyKeEmzEK9NP3HTqnk8E1EuttwRBVy8E7fjY+PUblvZSqq
	ixNIp2u/hVsALWC0/hJuYBaFFg==
X-Google-Smtp-Source: APXvYqzKqT4R8SObC1LwMgc7oT0iO2TSaMYUPaXWhrxP6+vgf7kWzLYoE22jClWrLF5LNRYQJ+U22A==
X-Received: by 2002:a37:98f:: with SMTP id 137mr11278917qkj.188.1567104244278;
        Thu, 29 Aug 2019 11:44:04 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id u7sm1494346qkj.113.2019.08.29.11.44.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Aug 2019 11:44:03 -0700 (PDT)
Message-ID: <1567104241.5576.30.camel@lca.pw>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
From: Qian Cai <cai@lca.pw>
To: Edward Chron <echron@arista.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa
 <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton
 <akpm@linux-foundation.org>,  Roman Gushchin <guro@fb.com>, Johannes Weiner
 <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Shakeel Butt
 <shakeelb@google.com>, linux-mm@kvack.org,  linux-kernel@vger.kernel.org,
 Ivan Delalande <colona@arista.com>
Date: Thu, 29 Aug 2019 14:44:01 -0400
In-Reply-To: <CAM3twVSgJdFKbzkg1V+7voFMi-SYQTCz6jCBobLBQ72Cg8k5VQ@mail.gmail.com>
References: <20190826193638.6638-1-echron@arista.com>
	 <20190827071523.GR7538@dhcp22.suse.cz>
	 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
	 <20190828065955.GB7386@dhcp22.suse.cz>
	 <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
	 <20190829071105.GQ28313@dhcp22.suse.cz>
	 <297cf049-d92e-f13a-1386-403553d86401@i-love.sakura.ne.jp>
	 <20190829115608.GD28313@dhcp22.suse.cz>
	 <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
	 <1567093344.5576.23.camel@lca.pw>
	 <CAM3twVSgJdFKbzkg1V+7voFMi-SYQTCz6jCBobLBQ72Cg8k5VQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-29 at 09:09 -0700, Edward Chron wrote:

> > Feel like you are going in circles to "sell" without any new informat=
ion. If
> > you
> > need to deal with OOM that often, it might also worth working with FB=
 on
> > oomd.
> >=20
> > https://github.com/facebookincubator/oomd
> >=20
> > It is well-known that kernel OOM could be slow and painful to deal wi=
th, so
> > I
> > don't buy-in the argument that kernel OOM recover is better/faster th=
an a
> > kdump
> > reboot.
> >=20
> > It is not unusual that when the system is triggering a kernel OOM, it=
 is
> > almost
> > trashed/dead. Although developers are working hard to improve the rec=
overy
> > after
> > OOM, there are still many error-paths that are not going to survive w=
hich
> > would
> > leak memories, introduce undefined behaviors, corrupt memory etc.
>=20
> But as you have pointed out many people are happy with current OOM proc=
essing
> which is the report and recovery so for those people a kdump reboot is
> overkill.
> Making the OOM report at least optionally a bit more informative has va=
lue.
> Also
> making sure it doesn't produce excessive output is desirable.
>=20
> I do agree for developers having to have all the system state a kdump
> provides that
> and as long as you can reproduce the OOM event that works well. But
> that is not the
> common case as has already been discussed.
>=20
> Also, OOM events that are due to kernel bugs could leak memory and over=
 time
> and cause a crash, true. But that is not what we typically see. In
> fact we've had
> customers come back and report issues on systems that have been in cont=
inuous
> operation for years. No point in crashing their system. Linux if
> properly maintained
> is thankfully quite stable. But OOMs do happen and root causing them to
> prevent
> future occurrences is desired.

This is not what I meant. After an OOM event happens, many kernel memory
allocations could fail.=C2=A0Since very few people are testing those erro=
r-paths due
to allocation failures, it is considered one of those most buggy areas in=
 the
kernel. Developers have mostly been focus on making sure the kernel OOM s=
hould
not happen in the first place.

I still think the time is better spending on improving things like eBPF, =
oomd
and kdump etc to solve your problem, but leave the kernel OOM report code=
 alone.


