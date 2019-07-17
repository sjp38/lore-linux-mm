Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08D72C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:09:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C338621841
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:09:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="YiDfBjaC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C338621841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53C7A8E0003; Wed, 17 Jul 2019 13:09:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EC0F8E0001; Wed, 17 Jul 2019 13:09:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B53D8E0003; Wed, 17 Jul 2019 13:09:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E25FD8E0001
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:09:41 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b6so12368495wrp.21
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:09:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xqEMkscsbY5oL9SftmgUyHWcTOrzBMfKcOHFnSqBMq8=;
        b=EoeiEQEn+YKYq1u+VUAlAl7d9B7jwXCEeXQwGunkjFNeIShsd03iQw/EwqGeKPYvaJ
         C0GG9eLeLXbyuawKOP5K789aog5S0gdkL70jPt2oD6IsUYMF6xvH1AIMteQORTr3RUTP
         pNeFmgFks4DSzKa7yRJC2/poURMcXYq2qRJV51oj0DyvlZojm2mCke1kLFSPoGwbFZ8X
         wKlLi3+U+VvEX2w6gj/Ux1tzGZBQsO433PSCMVPNlPrA4xAEmZ7JwGQ3C9ivcqEDKrCU
         2PkQX2TyN5tRqd84Cs1oS0jDrKi4I77OoVkAzLySeD3otBc3sWQS2SWdueEFRF/nhOk8
         ui6g==
X-Gm-Message-State: APjAAAUakSnwoaEcfc9O7bgd6N+CKEu8nH91isnVEimVwoePyoH0yEvw
	8AQNvO2Qz0vAM8r4BWaMpdxe6jxMvRMcxkmwunRtJiiKrijIIRchwtOpnTCXuxTlksJDyX6bKCv
	Yl9D+VLss6ja5ozWMwZQpp5HuN++5sLirffellwb8u7LgSqDly5AEP3e60KAv1yxaZg==
X-Received: by 2002:a1c:544d:: with SMTP id p13mr39155182wmi.78.1563383381447;
        Wed, 17 Jul 2019 10:09:41 -0700 (PDT)
X-Received: by 2002:a1c:544d:: with SMTP id p13mr39155144wmi.78.1563383380665;
        Wed, 17 Jul 2019 10:09:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563383380; cv=none;
        d=google.com; s=arc-20160816;
        b=uHWkCplpfE8lD2sXt6dE1a1rKAkeRpesA6XJUGDmXxSr9RCOj9MZAHIqqz7gE9K3P3
         bGC5il/RHdVj5TlpMrzmKLDwApF731hulgxTCTu2ONIt+IpAddge+5TkPcUujxc2i3ex
         GZPzpIbRhgS35Rz/YBs2dIqts5BqxFT5zkvW3BoBjl9Dy5ruoBYu/5tr23+QFtJUyZWt
         Vn16/baHTP8SZzxhwVJOGGjEXXh1mcL2B1ukv059lXnnEILm8SlfF2f/FDVllMavGw7B
         gs3+hsXKh+hs8m819EDV2TrCfyLYDdHR9m9/BYyEpr5Fq9mpxgQ4FeNRBAosxVFzIWBY
         nzXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xqEMkscsbY5oL9SftmgUyHWcTOrzBMfKcOHFnSqBMq8=;
        b=UaJngcYG4Bprg6flGqSMX7jkneJux1XSvREYq/xOEgO3iyFOA4bhEMrCG66j25oHMj
         uzGvQ2aRmOR7yObFzHNFCwylNxe5zT1hkTVZV3UVBEwSusNyqa5BCv/qMK9iKyS7V6/j
         iCj4HcMhzynHWL3NP+BYDNbO0ZsrF+QOXBIYMEcKNFzzXDCwgRlBIgjkgWhtDr+Lodgl
         N6IgIOay2STTCu9JVfp7FyfO5XtmobYfC3T2gM9oytA5RTzvQtth/w+nsVBFtE9lrgay
         mJF9wqWcxh189Uc7nCBzosA2YEiRkuY3dsW6bo4yjvYEU1pvROMDq3xUrPOqEPU3LNxS
         t+nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=YiDfBjaC;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor20018741wrq.39.2019.07.17.10.09.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 10:09:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=YiDfBjaC;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xqEMkscsbY5oL9SftmgUyHWcTOrzBMfKcOHFnSqBMq8=;
        b=YiDfBjaC+cpAv2JoO1VJ8Fmwf6QdIduUTHIC71WXTa68ghZUDgtajXY3RKhEIYP43z
         /IDmQogOEj6OGCmLywjon/V70o+tMzL9CIkwjodHBzM7jomyAXQd+CjaE38O+CWDZ0le
         Ujw3M9dIZviOjT7FJi87ZZjkNa8Ax1I+JBl9FySMQhNzcpnHWjdB63oiuQA15Qe52Y5H
         p4fdmIaIXtFlQKGGyDBfy0xDN+OO+eChSXMTztBlA0o0tJ0qngDkD0JePDkI8dx/mGAZ
         BdtbsH9mrGsaogzhFVEmiSBaVecfNqB1t48hOJwf0XYrJOrBAfWISw4hZVPJPgNN5DBD
         WN/w==
X-Google-Smtp-Source: APXvYqyAdOzPqW3HWrQP32WOm05reBgOXLygVi3Mj8KLfHriqcIebhnlOhWk1iCOFPhJD+OZKsr6eg==
X-Received: by 2002:adf:ce05:: with SMTP id p5mr7278143wrn.197.1563383380230;
        Wed, 17 Jul 2019 10:09:40 -0700 (PDT)
Received: from brauner.io ([213.220.153.21])
        by smtp.gmail.com with ESMTPSA id j6sm34119676wrx.46.2019.07.17.10.09.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 10:09:39 -0700 (PDT)
Date: Wed, 17 Jul 2019 19:09:38 +0200
From: Christian Brauner <christian@brauner.io>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Jonathan Corbet <corbet@lwn.net>,
	Thorsten Leemhuis <linux@leemhuis.info>
Subject: Re: incoming
Message-ID: <20190717170937.geeejwiawngmugwb@brauner.io>
References: <20190716162536.bb52b8f34a8ecf5331a86a42@linux-foundation.org>
 <8056ff9c-1ff2-6b6d-67c0-f62e66064428@suse.cz>
 <CAHk-=wg1VK0sCzCf_=KXWufTF1PPLX-kfSbNN0pk+QHzw7=ajw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wg1VK0sCzCf_=KXWufTF1PPLX-kfSbNN0pk+QHzw7=ajw@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 09:13:26AM -0700, Linus Torvalds wrote:
> On Wed, Jul 17, 2019 at 1:47 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> >
> > So I've tried now to provide an example what I had in mind, below.
> 
> I'll take it as a trial. I added one-line notes about coda and the
> PTRACE_GET_SYSCALL_INFO interface too.
> 
> I do hope that eventually I'll just get pull requests, and they'll
> have more of a "theme" than this all (*)
> 
>            Linus
> 
> (*) Although in many ways, the theme for Andrew is "falls through the
> cracks otherwise" so I'm not really complaining. This has been working

I put all pid{fd}/clone{3} which is mostly related to pid.c, exit.c,
fork.c into my tree and try to give it a consistent theme for the prs I
sent. And that at least from my perspective that worked and was pretty
easy to coordinate with Andrew. That should hopefully make it a little
easier to theme the -mm tree overall going forward.

