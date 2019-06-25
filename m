Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2E93C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 06:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FE2C20652
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 06:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FE2C20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=units.it
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB8866B0003; Tue, 25 Jun 2019 02:08:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A68CB8E0003; Tue, 25 Jun 2019 02:08:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 957CC8E0002; Tue, 25 Jun 2019 02:08:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD256B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 02:08:42 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g21so5142157pfb.13
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 23:08:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from:cc
         :subject:in-reply-to:mime-version:content-id
         :content-transfer-encoding:date:message-id;
        bh=nYszEFejn5YY8J9IUAx3CUfDver2Bzuv88lw7nNNCYE=;
        b=pvqrItEIy8rkYiXXwoeWkZ7sYJ+NNVmEldwlmXSLrSncVf4A4EskG8iBlSoNefF/ua
         qUIuNCP86SGlxjcYwTOoTjJohafGgBe5Ft7zAHykO28Fw7e0MRi9K4wy7+B3JCKUAp6o
         S23OWOklC5mqZs1WxHilpFKpEQ15QF7fdVw8fnJHWNzlz0ZHy2QAqaTrdqu1RFNM5GNu
         ap93CwUMMEzILrQM8IgH0uisHu4kw7eGyDIN+hRKcW28JbZcksBZNgM4p0MATC2sAyPt
         KORZ3ZGynYxQV8EH7XQilkvH+HnIJABXc0189quHR6K5bpjH7Mc6zO0ntCtnqsZaoJEo
         MymA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
X-Gm-Message-State: APjAAAVgDM7B11ZQr9LWuhV0z0L32y1uD+rq+FOEYW2ez855d8EIdn0o
	IyzXLLzXcls8va4UVnqquAZGLtlLrmoM/HSGYGgw2JPBNObqTCiLhHUqsbIaQxns+r4E7+cAf1i
	D2ozIPF3s/+u4Rpn7U7od1jJY4f6UM6OytrQacGEQ/5hYI2SFHqlgHWIx8dwPMa6p0A==
X-Received: by 2002:a63:c5:: with SMTP id 188mr37269355pga.108.1561442921926;
        Mon, 24 Jun 2019 23:08:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhleyYtdY9dR2KFGXODvGEFMtl+ZBuvrj/iX8Pk9kBotPAPnaaL9XTH7NR5mQvAP6gorOX
X-Received: by 2002:a63:c5:: with SMTP id 188mr37269294pga.108.1561442921105;
        Mon, 24 Jun 2019 23:08:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561442921; cv=none;
        d=google.com; s=arc-20160816;
        b=nv3Dh6/oXW40onwHgG7/4D0BPKFtYBacVIwlEuvw4lW90r4nY+9zGvE0H210wKY7so
         1ZtrT+4TzvagiTk6VIA0zdVAp6D4MRCkJkYOy2n9rLSez/6VpVsYQqS9SlGhFLO0eh0T
         2nOmICP2Hamsiw4sB6dGfoMHWHvf6heA/2GcL/2FxHrhU04jiw1eEeJxEmzLccA1gi7/
         QzcqsoTPUwezcwmODxqUGgaxFtwsNMn44liPle9WUxZuMnedhRdHYP03j/BvLoqjfyOw
         E9049xb7/tZ5orGoh0DU73Da+MP9OPi12yU1Wc+vIkMGtCx+GZAAFTqICRP/er4Y7psl
         7v9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-transfer-encoding:content-id:mime-version
         :in-reply-to:subject:cc:from:to;
        bh=nYszEFejn5YY8J9IUAx3CUfDver2Bzuv88lw7nNNCYE=;
        b=e2TQjpc0PnSuv4zNizUuoBhIAQQzEZG4a9f3kRoLB6n6wVoQsf7Qn+qe2KNOlPv2XC
         5EFuQj20ZckF7Wb9VDNDgABJ/vBbklf59W7ZlmcLF0kE2cI+85j66H6ITNIH5KhyZY1i
         /31YvxdoPWHQmVEl25Henwic5ES9XRcLnoX+/MKifiwf3tCfAscTc7U4THRlFoERgdIh
         qtEB3XJukofAilv7wFz/yxUNsSc/+wcu8BHRx4KSDAulJsRSZ3Ax+y16tQNUoQxSxrvj
         09sxY77y9rKo0EdMdReA762/mYRLdYSv8q6pAedm9AtAGeIEXkbhBNZZt+ma/WVvqM1E
         FaSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (dschgrazlin2.univ.trieste.it. [140.105.55.81])
        by mx.google.com with ESMTP id g18si12943852pgk.477.2019.06.24.23.08.39
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 23:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) client-ip=140.105.55.81;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
	by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id x5P68AK6032197;
	Tue, 25 Jun 2019 08:08:10 +0200
To: mgorman@techsingularity.net
From: balducci@units.it
CC: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org
Subject: Re: [Bug 203715] BUG: unable to handle kernel NULL pointer dereference under stress (possibly related to https://lkml.org/lkml/2019/5/24/292 ?)
In-reply-to: Your message of "Mon, 24 Jun 2019 14:19:32 -0000."
             <bug-203715-9581-IIXSanmjPc@https.bugzilla.kernel.org/>
X-Mailer: MH-E 8.6+git; nmh 1.7.1; GNU Emacs 26.2.90
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <32195.1561442914.1@dschgrazlin2.units.it>
Content-Transfer-Encoding: quoted-printable
Date: Tue, 25 Jun 2019 08:08:10 +0200
Message-ID: <32196.1561442914@dschgrazlin2.units.it>
X-Greylist: inspected by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Tue, 25 Jun 2019 08:08:10 +0200 (CEST) for IP:'127.0.0.1' DOMAIN:'loopback' HELO:'dschgrazlin2.units.it' FROM:'balducci@units.it' RCPT:''
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Tue, 25 Jun 2019 08:08:10 +0200 (CEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> I was under the impression that this bug was potentially solved. From op=
enSUS
> E,
> I know that a similar class of bug was fixed by at least 5.1.9 and comme=
nt 23
> indicates that for one user at least, this bug has disappeared. Can you =
confi
> rm
> whether the latest 5.1 -stable kernel is ok for you or are you still see=
ing
> problems? If so, can you repost the latest oops on a recent kernel so I =
can t
> ry
> determine if it's a similar or different bug. Thanks.


just tried a firefox build with 5.1.14 and didn't experience any problem

However, I wouldn't close this before I can successfully complete some
more tests, which I plan to do immediately

I'll report both in case I'll find problems again and also if everything
goes well (so that the issue can be closed with reasonable confidence)

thanks a lot

ciao
-g

