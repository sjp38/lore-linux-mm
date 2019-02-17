Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCE6DC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 16:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 629D82192C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 16:43:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="AxB7KhKr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 629D82192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2B888E0002; Sun, 17 Feb 2019 11:43:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADBCE8E0001; Sun, 17 Feb 2019 11:43:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F09B8E0002; Sun, 17 Feb 2019 11:43:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0718E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 11:43:08 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id i21so9569353ywe.15
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 08:43:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=jbbsl1atj1zK3IKfTsL4IYE/Yg6CzOPeRS02hGXPims=;
        b=lCvvWdu2OE0lOHBT+V9cmMIVSYSYloSfjMal84S+NvwBDeQBpNs6WzQVXQZZ7KK45Z
         yCv7LJEx6dlOvbXjRibhA3/VDzfUbpaztTvnpLpfIYg0n2IHc4H7NF+STXGVTmSXEIfZ
         DL34yoeY6VJqs08kA4d4W7XFvkU1j5t8q0+/kUEsn01Q+9ukMShPaKFDVNwZ9eI4Hgfv
         POwdjAW9MOG4oCHFvygjH5bpKA9Hks9iHDQ4LGWakZZGGfJsFvbdzaE0ZTNI3eKOZBVC
         8QVMTuvDVWN396cqiFX9v6cnu+C9sGbMypaS03bHvE195y5+4PGsU4gKUesOe3tr6e3H
         fbtQ==
X-Gm-Message-State: AHQUAuZpG+Z6LbJ94+ciGoPbwgwJTtu8W5xBcZ9EVF1DZXwcMA2nZhua
	wd9C5A2k5l8CkSf5bsDkEgARgeqlA4pBB5oPuvwA1FDZgmMXPdTEN1+FsRAf5+N13tJzCbqWIZm
	BUxEZvCw9Dw/6UX7QTAjiT3osDGnl73LL3IMaiKQiTMZ4374X0UWlUJxFevZjRjcgpA==
X-Received: by 2002:a81:5683:: with SMTP id k125mr14853966ywb.436.1550421788106;
        Sun, 17 Feb 2019 08:43:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZHmcOrgkU6WUIZS2t7QIlz73vIO/LmXIvsiHVZsuy8kh+gP71GqI92GkfRZ7zBd0yJ7UBd
X-Received: by 2002:a81:5683:: with SMTP id k125mr14853935ywb.436.1550421787300;
        Sun, 17 Feb 2019 08:43:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550421787; cv=none;
        d=google.com; s=arc-20160816;
        b=R4igeT2glbe00uI7IuiMFkZf/tjMGaqnHsuSSJfGc7DT/Rl1Xvc7bM+deEQOLs6TV2
         ZXoEfMr8I+Xp2hCU46JKciGHTzSb9nrjudaJd4mtvzLYsdnq62sdJhej6dSfpXHI7dWw
         DzpUYX46/qS883i56XTukRqPn6q5nCqTOeaOEeWICuD1jM6s5RTM2mS81yhc9hoXXY0t
         THShryHKiqAgqCBKatnRqQUFLF7kU9vZIXDpcdagtF3fy/HEtHgCn0jxlm0hCMXljmg9
         t5FSWzsuF6IZMsj98Spmi0JLurm70txDLP6WFT8g+tSLYHtC6Y5XpfE8YzJHgpUmXE42
         IU9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=jbbsl1atj1zK3IKfTsL4IYE/Yg6CzOPeRS02hGXPims=;
        b=unNf8zfsEHEuMPF5rHDvvlWC7y6x0Ge6irVmaxB1kEX32PLoWXMTXKl0GqOkWPu2nu
         lmq7+e+anHotCoKjqeAnn0k6NVyZQdaD4gJJJih8l/RK5i4L08HMpSX9HVVS+BRzsj3z
         mqwx421mqxc61C9oVTsYBlGaH7sPIj2Ua1fKqnvoH+NQOBHOGbKFzW1ZB9QyuWD4r3sl
         rVEWYgi9KJUZY06mCFR+uDf0/p3jInqa2NTA1ZNZ1iZdrbTIkp1qIcPgjfZyOTI8oVYP
         ZMrczcykUKAHVciVeQA1QBjGspLrhkiKwdSvjMWH0fdx2/44HO3IwAfw9sAAx6pQU/Nr
         ZTfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=AxB7KhKr;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id i3si5827717ybe.457.2019.02.17.08.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 08:43:07 -0800 (PST)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=AxB7KhKr;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id E72CA8EE229;
	Sun, 17 Feb 2019 08:43:04 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id e_vla_Vsu1Fx; Sun, 17 Feb 2019 08:43:04 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id E570F8EE03B;
	Sun, 17 Feb 2019 08:43:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1550421784;
	bh=oYUumXGYz666qKgagUFB+74ogRb95pKBm2RP3wr9yuo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=AxB7KhKryGDa9yF7k+yo7YsvqWEyMjPsH77u9Iw8E/SkMSLgTN1U+BExWQuihMgWK
	 h0JbHXekH2gsRcL5QBz3jYI4mkELmx9BH59utg3vWYFIUa/RdhfYMJeKRJm+3uuyNC
	 sQXa1Yig75ugi00Y7DXT30bOUPSSVkQFUVWCPpVw=
Message-ID: <1550421781.2809.2.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, lsf-pc@lists.linux-foundation.org, 
	linux-mm@kvack.org
Date: Sun, 17 Feb 2019 08:43:01 -0800
In-Reply-To: <20190217080146.GF31125@350D>
References: <20190207072421.GA9120@rapoport-lnx>
	 <20190216121950.GB31125@350D>
	 <1550334616.3131.10.camel@HansenPartnership.com>
	 <20190217080146.GF31125@350D>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2019-02-17 at 19:01 +1100, Balbir Singh wrote:
> On Sat, Feb 16, 2019 at 08:30:16AM -0800, James Bottomley wrote:
> > On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> > > On Thu, Feb 07, 2019 at 09:24:22AM +0200, Mike Rapoport wrote:
> > > > (Joint proposal with James Bottomley)
> > > > 
> > > > Address space isolation has been used to protect the kernel
> > > > from the userspace and userspace programs from each other since
> > > > the invention of the virtual memory.
> > > > 
> > > > Assuming that kernel bugs and therefore vulnerabilities are
> > > > inevitable it might be worth isolating parts of the kernel to
> > > > minimize damage that these vulnerabilities can cause.
> > > > 
> > > 
> > > Is Address Space limited to user space and kernel space, where
> > > does the hypervisor fit into the picture?
> > 
> > It doesn't really.  The work is driven by the Nabla HAP measure
> > 
> > https://blog.hansenpartnership.com/measuring-the-horizontal-attack-
> > profile-of-nabla-containers/
> > 
> > Although the results are spectacular (building a container that's
> > measurably more secure than a hypervisor based system), they come
> > at the price of emulating a lot of the kernel and thus damaging the
> > precise resource control advantage containers have.  The idea then
> > is to render parts of the kernel syscall interface safe enough that
> > they have a security profile equivalent to the emulated one and can
> > thus be called directly instead of being emulated, hoping to
> > restore most of the container resource management properties.
> > 
> > In theory, I suppose it would buy you protection from things like
> > the kata containers host breach:
> > 
> > https://nabla-containers.github.io/2018/11/28/fs/
> > 
> 
> Thanks, so it's largely to prevent escaping the container namespace.
> Since the topic thread was generic, I thought I'd ask

Actually, that's not quite it either.  The motivation is certainly
container security but the current thrust of the work is generic kernel
security ... the rising tide principle.

James

