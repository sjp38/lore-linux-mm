Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 068E8C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:02:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEBC620880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:02:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="iIMtsh8q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEBC620880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 556E16B0006; Mon,  5 Aug 2019 08:02:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B6066B0007; Mon,  5 Aug 2019 08:02:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32F486B0008; Mon,  5 Aug 2019 08:02:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D42B56B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 08:02:00 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g2so40895174wrq.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 05:02:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RZH42r0qSuasH0iuqkft0iVsurL7klddbLTSy94oFU4=;
        b=ctLfaOybg3RlB5puJbrR/tK6z+h2uWwhgz+L/z9z7U+Xp0yy1VuazOVjmqzQEvteo+
         Bn+Pc+uiLY33TJ7PYfoZCKyJq+ROqA/TuUYs6q/2V8u1xQIuZGKxj7fwgm1lKVrRcV33
         YQBs9huzO70kQL/pHI+0hRh9Cjs09Ar1Y1WgcZeGMdEERxzqOZYR15UxujOgzyBLZB/K
         gcBc3x0FrWNVGEEWMRnJgUcAQ61p38f0Xcgs1X2uAjSsNZU8AZqB5Lb0+wk5tI6/DnQP
         7KYovs4gmG7nwzBQm0xk44J7DBToVRTvWHhgPQ+9FpU/PMxecK4fIy+8RtOIbbacfvZk
         1q8g==
X-Gm-Message-State: APjAAAVGMnL27BMpeLdF9cckTDC0oSouyFfsYnvya6tQoueESapTpt0j
	isK3Hs4/uRD/BUKz+lw6BDQcT7PLB4emrjzmJ6ef0Sarvyxabn0zRqE3jmPnlYNL/siJgVK8ih3
	I/q6/lWFeWvpnKEVG6P1/J+pkNq1F2Xa3G7BiHUNsK/859OowZRFyy9qycidYrSIQfQ==
X-Received: by 2002:a5d:54c7:: with SMTP id x7mr132978513wrv.39.1565006520404;
        Mon, 05 Aug 2019 05:02:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh3CqydWclCd+gr9BgT4nOOzAJhFnlvU6PzaJ0+ep+zOagbwSPmlVKVlap6y4ycpcox/Zo
X-Received: by 2002:a5d:54c7:: with SMTP id x7mr132978452wrv.39.1565006519511;
        Mon, 05 Aug 2019 05:01:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565006519; cv=none;
        d=google.com; s=arc-20160816;
        b=L5rTlLCJynEzd8p/7kVNJ8gjzCQMAaTSppe9Z54Jg+dopr88tUEgzYPZmev/2pom80
         OSP5+vaiYnf5EnihyhKWyGCB3naPxdqbulEFLuKIz/rAdG25+h2ycqiXv468aYfGDq09
         g4Ly2LX+OhzmK3EROb+8rURBTFvzpfjJFCCXUdIfsLC7g5ndEg2MeVRiSMk0+GiFTH3f
         vdjRHlmXZJ+2opVAT72XuPsZkHITzSH/iyvJxLYWOTWw4dkQi6FybHP2s7EkpAZlnSSl
         SFSIZGgwCpLqwJznw3WwVe+KAKQN5ud/EiZZswTFXdA+aybpo97Aszzhl/ZB403Ftc5/
         pydA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :date:message-id:from:references:cc:to:subject:dkim-signature;
        bh=RZH42r0qSuasH0iuqkft0iVsurL7klddbLTSy94oFU4=;
        b=qEZF0onMAMs5ojyetVM4q3eJSfytEhU/xp2NZMm0g54mUXt/Pw108nab/0dANS9mFq
         kls69KDudd+cfR/n/Bx8D/j0Nw+Ggiv76otSMtOTxMkFohQyBJnk+k2uZrULijLqbAgH
         XMJ5dNH/E95rJkLxfUCKR9WOiTKeOG4eXp8xh/5oiyrT04vkLzIbHAyUFlfr0BzsgeBp
         DqoM5NRHY54lmC1SUdIh+XIh8kvk0QpzrJAcelI8qvT8aUJKaMIm4GXicfuXKtnT4Wim
         G/Jh+yaVtXoxPUb2qnNbbZWu1XFtHrOwTYizt/WiFkHl9vMIKaIx/L+OTuolkGDT5Evz
         pYxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=iIMtsh8q;
       spf=pass (google.com: domain of aros@gmx.com designates 212.227.15.19 as permitted sender) smtp.mailfrom=aros@gmx.com
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id d16si72186925wrn.10.2019.08.05.05.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 05:01:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of aros@gmx.com designates 212.227.15.19 as permitted sender) client-ip=212.227.15.19;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=iIMtsh8q;
       spf=pass (google.com: domain of aros@gmx.com designates 212.227.15.19 as permitted sender) smtp.mailfrom=aros@gmx.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1565006506;
	bh=KmcLdHf0XwKTJJgL+H3RVxeu5Ne9CquLQEwQPSvQMcY=;
	h=X-UI-Sender-Class:Subject:To:Cc:References:From:Date:In-Reply-To;
	b=iIMtsh8qB2coFc12upwLyWLPCpegsOyMNCIqdt6+P1VldhE9r1JiTpVjQzf0zFdu8
	 /U7Gt5LJW4Sxs4vg/VtCFyxSwY1Uqv+QfQfJ7krIYXXTxxXoFVCbohPqgIRJtPYZTt
	 RFrgBO4gM7Z83i5D6/9VW75w/UukoKQqZu6iEdPE=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from [10.80.10.6] ([196.52.84.6]) by mail.gmx.com (mrgmx003
 [212.227.17.184]) with ESMTPSA (Nemesis) id 0M6jIK-1iHtle1n8e-00wVpV; Mon, 05
 Aug 2019 14:01:46 +0200
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Hillf Danton <hdanton@sina.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190805090514.5992-1-hdanton@sina.com>
From: "Artem S. Tashkinov" <aros@gmx.com>
Message-ID: <91360b32-f20a-9f2a-838f-bd00e991db40@gmx.com>
Date: Mon, 5 Aug 2019 12:01:43 +0000
MIME-Version: 1.0
In-Reply-To: <20190805090514.5992-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:fwHdWITLjRI+5T9B5auq4PfprFdsXP/AYtLPf0YQchM4VGI0l4N
 1cdcOiAx8gY1azaY6k1Rk9Yh1nIq+LpDAzHIDJzXmPO0XAaoM8pIB1Yet7tSfQLa6h1eg2Y
 9xDOuwrbmAwQR9XZAZ+z1We9AJyR8nKW8q3u3bo8u461sIoGUMyIrtICdRXd1/Qmek4PA3s
 wy/D4t23NlwZ9fLUcEPsw==
X-UI-Out-Filterresults: notjunk:1;V03:K0:fCNy7Kaw2TU=:TGdcb/4vwRcYIRAUgaiQJ+
 2Ip3rrEOk3dVwx3k7sTysuG8eiidhH5MRSfX97tf7O8CelPpYodeZsrQyTLAsUKkDuQo0+Eh2
 KbfDHEOsks0m/Ba52aqNlXvkggZrUTuY6JRKAMYffFCejJlKRYIejcmmBiHUY+eH2IR2eGAo2
 WG2egJArJd6G+35QclPh9FcRSHMYu/eLIOAiYeOC9NCuYkVpHypd67WKRVJQxDE1oqUSv8LlP
 gjeNalPkwNACua/OR6IfawJ5xBN5CTJAqcoXsfxPd4hrB+77HNnRIh7i+kPZlBNMZuAjQ7P8s
 170MOAblDh9VtD8uID1VgbYkTcw6frkpwATF8X+/Son6ei74L22tgeVRxW9sdN5gjn9wRz5tJ
 8NGnUGq+y603ovHGYnqqwwBzutX+A4s67xmQM3OgtBc4fbiubeX6ABkKfuVWbiaBjsJMrUhBt
 ICvZ5VbdRBpKjWh0pKtt2IKUedNy9apMNWSyr3f2zwGnZqpE25+64WNzdrWk7LKdVN3ry+UJN
 AjYHItEFaZZxzaX45DUilehlESyBtEDaS+W6+qPrbkhFq9Nvx/xp2dDrcOOtj2THnmmP9AYBK
 pyiUVTjFj83CPWF2nyJCJnp8ZkT98qzuddE8QsOiSur9XES3dPlGEdlozsyPind2BAAEtnkQo
 eDlArJKQ6Ppq6E0Bo+hOYgwWU/WTQ/8+YET6BIXSCw7410Wu7+LoxQDvN9Ly21X7WoSGT5R/I
 ZhCRwh3NBMOLaVZKBl3t6RpiRRHIbbFzTAB8Vjf5ToUfFmv5qFr9wKggtytMkJEAaisaswLjo
 FtTSb+DhntTzIEjkTe4R1oodw6aNFVLVDUlBxO27y/c3WHLoBJZ9yontI+/rzNiRyyBaFXAGE
 wFdHvolcSxvEER6sXnnD6IHlpQNw45qPWAuZoXpZDBKjHxopOse1NTR61Fl1kMviqEIAvy4i0
 cL94ueGli4wouXH1BFezu7zPC2/1t8qD8/uWUhdPboLJ0/viYimL1pTBFEdXXhGZZDyWyi8by
 YK6fZMJfc17z8/3faZKnO1c+MsSXuZnkigJN0rkdZSc4Lo5ZN9Fv/6iZzQ8WYtTERj9tXomFC
 G600hDIOQChv9MAf9ORIjc3BxrcMhY/LXSBhR99DqI8vCuDv/d5JH+AXO6MEheVYPXiwOENlq
 0S2jk=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000696, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 9:05 AM, Hillf Danton wrote:
>
> On Sun, 4 Aug 2019 09:23:17 +0000 "Artem S. Tashkinov" <aros@gmx.com> wr=
ote:
>> Hello,
>>
>> There's this bug which has been bugging many people for many years
>> already and which is reproducible in less than a few minutes under the
>> latest and greatest kernel, 5.2.6. All the kernel parameters are set to
>> defaults.
>
> Thanks for report!
>>
>> Steps to reproduce:
>>
>> 1) Boot with mem=3D4G
>> 2) Disable swap to make everything faster (sudo swapoff -a)
>> 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
>> 4) Start opening tabs in either of them and watch your free RAM decreas=
e
>
> We saw another corner-case cpu hog report under memory pressure also
> with swap disabled. In that report the xfs filesystem was an factor
> with CONFIG_MEMCG enabled. Anything special, say like
>
>   kernel:watchdog: BUG: soft lockup - CPU#7 stuck for 22s! [leaker1:7193=
]
> or
>   [ 3225.313209] Xorg: page allocation failure: order:4, mode:0x40dc0(GF=
P_KERNEL|__GFP_COMP|__GFP_ZERO), nodemask=3D(null),cpuset=3D/,mems_allowed=
=3D0
>
> in your kernel log?

I'm running ext4 only without LVM, encryption or anything like that.
Plain GPT/MBR partitions with plenty of free space and no disk errors.

>>
>> Once you hit a situation when opening a new tab requires more RAM than
>> is currently available, the system will stall hard. You will barely  be
>> able to move the mouse pointer. Your disk LED will be flashing
>> incessantly (I'm not entirely sure why). You will not be able to run ne=
w
>> applications or close currently running ones.
>
> A cpu hog may come on top of memory hog in some scenario.

It might have happened as well - I couldn't know since I wasn't able to
open a terminal. Once the system recovered there was no trace of
anything extraordinary.

>>
>> This little crisis may continue for minutes or even longer. I think
>> that's not how the system should behave in this situation. I believe
>> something must be done about that to avoid this stall.
>
> Yes, Sir.
>>
>> I'm almost sure some sysctl parameters could be changed to avoid this
>> situation but something tells me this could be done for everyone and
>> made default because some non tech-savvy users will just give up on
>> Linux if they ever get in a situation like this and they won't be keen
>> or even be able to Google for solutions.
>
> I am not willing to repeat that it is hard to produce a pill for all
> patients, but the info you post will help solve the crisis sooner.
>
> Hillf
>

In case you have troubles reproducing this bug report I can publish a VM
image - still everything is quite mundane: Fedora 30 + XFCE + web
browser. Nothing else, nothing fancy.

Regards,
Artem

