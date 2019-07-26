Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDED9C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:15:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A23521951
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:15:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A23521951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D7956B000A; Fri, 26 Jul 2019 12:15:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0891C8E0003; Fri, 26 Jul 2019 12:15:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E91468E0002; Fri, 26 Jul 2019 12:15:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2F96B000A
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 12:15:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so34363630edx.10
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:15:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cEplI2FQib5bKrwdVlWTz1XxCI0q72H0HWyhogv2iNE=;
        b=eMXtyDBHZvWRADZsHM0qFjHqZQnaQNgt918tb4bnWPUyR9ywXkFoFlcqXDG7koCPhq
         rbVffQMqF1PdNzyrSS7BAoHB4Qyrz5qtcVAwitmO0eaeBFia94L/MMzz3cFpEsD1Dtob
         fmeUIHhYcGAi+PM0epGWbZUKVP4zRXnc4+y6YobgkPLIPYeZbSIZZcJanS3LOGHKdqlB
         Yz9FPsBfpdQH5p88R1mMsOKDKarclU1WMms+tNyQ4NVzmffdyUNIzpFQddo3GToIWmYA
         mLoEquuEUqW0u9to92a9Pz6sYdHw5SBIHCZq8jnBhrsxbfqxJS4A89W66+jO3BpU4EcK
         k8BQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV/pxwEHXIERSbfFwV+5/TCpiAGeK1bPwswK1+T1bSsJxYzyWUg
	0VG6ZVYc4LE1+POI+La/a/FTJCYXdqblay0EjftUdPYc9d8CmfOGONyiZ+Yt0bgMEVYasBIdMH4
	Xg5/9a2jcqZr6bgZkdP1qz77lRRfo/1AdUGey8hjuXhf6EWb7Gt2Ll3O1MfBsKBR9nw==
X-Received: by 2002:a50:ad0c:: with SMTP id y12mr81809969edc.25.1564157736066;
        Fri, 26 Jul 2019 09:15:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1wZtCp+HuiQttzZ9oUR0Jv824qr5gjHC8tHyb6IkjfJiyw3vnN0N6wcnRVbDugypH7FeE
X-Received: by 2002:a50:ad0c:: with SMTP id y12mr81809912edc.25.1564157735379;
        Fri, 26 Jul 2019 09:15:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564157735; cv=none;
        d=google.com; s=arc-20160816;
        b=ZYIFDredmThktjxoPX2hiclk9nWIKfD4xx9/ZB/cmGtRgYFfbp/I6/FLRvLA8wQf9H
         xD1miMnict+xAbbaGE6e4JVByFB05Zx17Py4j8gR070bnTuihSPNxhDrpMn/zqjngOjX
         Z6+vV1eZ79giIymHl+kFtfRzkQPS+tao4sejMNwTNRhcs+PBq8x2Cu9UMkMXcURUvgp2
         3dHxBS+zJO0OMDYcfbtUuvpGKrMU0bamlpeUcVtemEGYRj8wYYM/2QHRy3ky00lQgF4w
         ELwM3WiQiX5cKOZFNpOnwIAayFy3IpCkJvsVdiRGk4feS2gm/eBdzpCqRogSVjLXAdkv
         Bw1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cEplI2FQib5bKrwdVlWTz1XxCI0q72H0HWyhogv2iNE=;
        b=hIYXO2G4nKbrgjXlMqx0+P9S00qBg0AHyblVLiOURxD9ASDyaNnQ4HyV3Fgp9OH+Yq
         5P7wCiqSUTZKysbxLLrVa57W2HqzlvPruxuDm1S1Kfe2ZOLayLvT+Tk7S4SLzXkC9lCm
         GYUyZ7ayPaKHBp8nGDliQEASU8UoDZeCkyfI2gb9kD495X8VYc3JdITODmR047M4PJqD
         BZxsrJzqg3Dl1uNAlcVJgd9rZ5akDEiCAF/+yyNfnMb2Mb5HolP3mjA50fYyxZo5g0+6
         wHhSkUOU3B+yNJ4udyqCmEwzaIq6oVOQykmRQjqzC7Eyr+8eOxU39W5hwQsUxYARW4xr
         Zhqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id ny24si11495741ejb.78.2019.07.26.09.15.35
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 09:15:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7F570337;
	Fri, 26 Jul 2019 09:15:34 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 457483F71F;
	Fri, 26 Jul 2019 09:15:33 -0700 (PDT)
Date: Fri, 26 Jul 2019 17:15:31 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+a871c1e6ea00685e73d7@syzkaller.appspotmail.com>,
	alexandre.belloni@free-electrons.com,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	nicolas.ferre@atmel.com, Rob Herring <robh@kernel.org>,
	sre@kernel.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Subject: Re: memory leak in vq_meta_prefetch
Message-ID: <20190726161530.GE2368@arrakis.emea.arm.com>
References: <00000000000052ad6b058e722ba4@google.com>
 <20190726130013.GC2368@arrakis.emea.arm.com>
 <CACT4Y+b5H4jvY34iT2K0m6a2HCpzgKd3dtv+YFsApp=-18B+pw@mail.gmail.com>
 <20190726155732.GA30211@e109758.arm.com>
 <CACT4Y+Zf-p7CTRZd8x+2ymAXho2tM_5hLCn3ODJXPVuocMxwbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Zf-p7CTRZd8x+2ymAXho2tM_5hLCn3ODJXPVuocMxwbw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 06:05:32PM +0200, Dmitry Vyukov wrote:
> On Fri, Jul 26, 2019 at 5:57 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> >
> > On Fri, Jul 26, 2019 at 05:20:55PM +0200, Dmitry Vyukov wrote:
> > > On Fri, Jul 26, 2019 at 3:00 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > On Wed, Jul 24, 2019 at 12:18:07PM -0700, syzbot wrote:
> > > > > syzbot found the following crash on:
> > > > >
> > > > > HEAD commit:    c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> > > > > git tree:       upstream
> > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=15fffef4600000
> > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=a871c1e6ea00685e73d7
> > > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=127b0334600000
> > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12609e94600000
> > > > >
> > > > > The bug was bisected to:
> > > > >
> > > > > commit 0e5f7d0b39e1f184dc25e3adb580c79e85332167
> > > > > Author: Nicolas Ferre <nicolas.ferre@atmel.com>
> > > > > Date:   Wed Mar 16 13:19:49 2016 +0000
> > > > >
> > > > >     ARM: dts: at91: shdwc binding: add new shutdown controller documentation
> > > >
> > > > That's another wrong commit identification (a documentation patch should
> > > > not cause a memory leak).
> > > >
> > > > I don't really think kmemleak, with its relatively high rate of false
> > > > positives, is suitable for automated testing like syzbot. You could
> > >
> > > Do you mean automated testing in general, or bisection only?
> > > The wrong commit identification is related to bisection only, but you
> > > generalized it to automated testing in general. So which exactly you
> > > mean?
> >
> > I probably meant both. In terms of automated testing and reporting, if
> > the false positives rate is high, people start ignoring the reports. So
> > it requires some human checking first (or make the tool more robust).
[...]
> Do you have any data points wrt automated testing in general? This
> disagrees with what I see.

I'm fine with automated testing in general. Just that automated
reporting for kmemleak could be improved a bit to reduce the false
positives (e.g. run it a few times to confirm that it is a real leak).

Just to be clear, I'm not talking about syzbot in general, it's a great
tool, only about improving kmemleak reporting and bisecting.

-- 
Catalin

