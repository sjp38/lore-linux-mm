Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE9EAC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95B332182B
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:13:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="OLl9lkjd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95B332182B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A7D16B0003; Wed, 17 Jul 2019 12:13:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2320E6B0006; Wed, 17 Jul 2019 12:13:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1214C8E0001; Wed, 17 Jul 2019 12:13:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id A20766B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 12:13:49 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id g13so1478068lfb.2
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 09:13:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EMkHfaU67BchYChypR6OGoPRtecIrRaXkSjINopMJ7E=;
        b=AoOeB53/fDckrTgEPdUYUsuz/QaSWWRpHu+bRwoo0dqCs8DeMCenN5FsqdBJ41Kfwf
         kt+qbNRufnLua1RUA0eCAqEfIkzn+WUEXEwRGmCZ5ceWDwASmo7Q9+8Hdylp2XIDyaID
         fiM8b4VDQh2owTYeXQzbFvoPIK/TwDtdMCOUA7m1xsAdGG5q9tYkebhIBysFLX53ZBWc
         MHCxS0KGIvyrFdjOZ4PAC46YLkK2X29yVNcQE7UWGEjilANg8iKF9yHpZlsOG8f+bULk
         davyyqvQUhzLieAtLm9O/VUt101RLLl17/PTEE0JMP8+LkP2COWDHfep56VDXr4zGVc6
         MC7Q==
X-Gm-Message-State: APjAAAVKi/EHo1q0SAt4fWmwf8uiFeeSeGUbRFboMS83T9VdFPqRXg1h
	A9ii76PCAPcXY+YYN7hVVwARmgEzwKR2JVyWhTOODVwlFRZLmWzeXsaZRzg8vYdHWDnJQTL9sDb
	GadYTvknxQSMtYEDk8GGuiuJVmbfJSW5kNT8UaP7wmEyHdbve0yW4qjtjx+wwiwqjLA==
X-Received: by 2002:a2e:988b:: with SMTP id b11mr21067013ljj.110.1563380028787;
        Wed, 17 Jul 2019 09:13:48 -0700 (PDT)
X-Received: by 2002:a2e:988b:: with SMTP id b11mr21066972ljj.110.1563380027891;
        Wed, 17 Jul 2019 09:13:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563380027; cv=none;
        d=google.com; s=arc-20160816;
        b=sdhYMIJvXWoNQReVv8k5gJTr3Oy0Rt12nRnnNOgWcp88lljjIV2k3YgkXVPNTPeBMp
         2pbzZkGoU01F7AiH1pGesX/0r0/6Sf0DonCK9g7DouWad7Jl5vrc/1FQLUQ0jxB74iFp
         XVnbBKlcW2AybMuzZwGfqhBDKc96DL9/+70upoxoP6eas2DRrCoI2zsawFkEelNXl5Pv
         hOTUv9qgQYq7PnqF6WE5Kdzze+3pZZ2tZ8fl0A5l4xhcBLzmF4I7MS9oVSh4rR7rfVie
         dAffrQIU+oEVqBWKEuoP5Nl6vGuYK6EO4VTR6+cZ1GsjnwOBpb0hDzA/UGApGGzkaNdi
         0/rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EMkHfaU67BchYChypR6OGoPRtecIrRaXkSjINopMJ7E=;
        b=R/NW7g0w3rgItxMYXRMEBrjyB2IUfsXSt+sHYEwciufQLPXDG6QhHwmlB3lw0xr3R4
         qufQpd4wdSOAj81aUcqTIGJm/IHTAXuVpn4qow9anwqDoyyD9AQEeMBTbKHiyc/sycWS
         9cfo1CXkPbC+PDdw9EURsJGydnE7BT6BCcS3vMcs883WXf46m1u20NOpE0Dp7A4kBnMO
         +NsUDYOHJlbaSmDNEAUIzE4Nk85YSkV09Im/zXi56mDI9uen+BgRlvHQnkTQC5KUD73J
         A/MzK8XU//owu/bdWS1PEd1RXo9/EdrXqrzjld9rk7lNiVdgEFtLr1dhf5xRF6+lZnna
         Rcug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=OLl9lkjd;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c19sor6457078lff.3.2019.07.17.09.13.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 09:13:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=OLl9lkjd;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EMkHfaU67BchYChypR6OGoPRtecIrRaXkSjINopMJ7E=;
        b=OLl9lkjdcYSnuxCTAJOQsNMwFOpw8ryeimFhE1ANkVONZVt21tze74/Y5gnh0UZvqA
         dhREWrcTisRLQxADCiSzp92AqaDsndFz3EbTrI3SrJSW2GB+VRBEXQJckND8M1PEm/wd
         WW+T2kuE/xXCQFTAUkUGPcsGrhkWVUdw2wFp8=
X-Google-Smtp-Source: APXvYqxlBDGx68Y5JGmHAtIuWUKhZLugrxXRo1op5WGiKiNWVn5aNKuOJ0pS53MiBVm7iyUlOxj13w==
X-Received: by 2002:a19:6904:: with SMTP id e4mr18707313lfc.156.1563380026355;
        Wed, 17 Jul 2019 09:13:46 -0700 (PDT)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id m17sm4548445lji.16.2019.07.17.09.13.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 09:13:45 -0700 (PDT)
Received: by mail-lf1-f47.google.com with SMTP id u10so16914464lfm.12
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 09:13:45 -0700 (PDT)
X-Received: by 2002:ac2:4565:: with SMTP id k5mr18364164lfm.170.1563380024874;
 Wed, 17 Jul 2019 09:13:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190716162536.bb52b8f34a8ecf5331a86a42@linux-foundation.org> <8056ff9c-1ff2-6b6d-67c0-f62e66064428@suse.cz>
In-Reply-To: <8056ff9c-1ff2-6b6d-67c0-f62e66064428@suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jul 2019 09:13:26 -0700
X-Gmail-Original-Message-ID: <CAHk-=wg1VK0sCzCf_=KXWufTF1PPLX-kfSbNN0pk+QHzw7=ajw@mail.gmail.com>
Message-ID: <CAHk-=wg1VK0sCzCf_=KXWufTF1PPLX-kfSbNN0pk+QHzw7=ajw@mail.gmail.com>
Subject: Re: incoming
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Jonathan Corbet <corbet@lwn.net>, Thorsten Leemhuis <linux@leemhuis.info>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 1:47 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> So I've tried now to provide an example what I had in mind, below.

I'll take it as a trial. I added one-line notes about coda and the
PTRACE_GET_SYSCALL_INFO interface too.

I do hope that eventually I'll just get pull requests, and they'll
have more of a "theme" than this all (*)

           Linus

(*) Although in many ways, the theme for Andrew is "falls through the
cracks otherwise" so I'm not really complaining. This has been working
for years and years.

