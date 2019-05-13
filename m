Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2E6FC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80E9D208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:51:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fyu+eEyt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80E9D208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D3C16B027C; Mon, 13 May 2019 11:51:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 185176B027F; Mon, 13 May 2019 11:51:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0741E6B0280; Mon, 13 May 2019 11:51:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1DB66B027C
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:51:19 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x13so9439181pgl.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:51:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ORppQGlcfBf3WPuXFmYvQJ48TDHuiN6acZ7PdcalqYE=;
        b=iOjnLyZPgJ+n30fklzQARbBfdQm5WUDMa8Abs/I64ScQ3yagdBBuvUWDMqzurfAiJ9
         TkellQfyCZ2FdH8vhYDNtDoZASJb6yrx1Up4vPrKj5mDD5VDiEtGfMx5yMeYGLdDAt09
         GeTr1hbzz2tHnJYc5JjHDhl6DeaQR9r9MN5lYcMq+mBIhA1ZgFAT5g1yfnCcrdnq1LFM
         J3XTD9MTuiYhk5PZWMSnIRnElDnP3VnqSVDeElIjNeuyEkq7lUBH5nxFLDXj5piJbSWT
         4BhEwkih2Tjj73Q2hiw2kCqTOrxxER7KyKqMucWpPSKZ7H0Kr+INgpd4tA1GMuEIbhRk
         1wBw==
X-Gm-Message-State: APjAAAXJ2AwStSjCvQGThJx2/WpsIu31hTI3Pmel/IOj9+mEIsKvjb3e
	9b/mirE7lPInjXI0V7Cf0aKjKkk966H0+GK9A4L6IcXMxgAdJh12gWkPnQ617algFXjUnCoIa1S
	cRVjMVPMakkC9KzR4hm+0Bd0iXHZcrijelfJfRH3JFi8M5lhNLk0sRWCtlni6Ful5bA==
X-Received: by 2002:a17:902:5c6:: with SMTP id f64mr32080922plf.208.1557762679485;
        Mon, 13 May 2019 08:51:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrX+Jez1Pu/CNOnqIJ/EWPfEeBq26XndApTOybNiFyBFs3sS4d6axW8yKvrFkDpwUJnK9E
X-Received: by 2002:a17:902:5c6:: with SMTP id f64mr32080820plf.208.1557762678577;
        Mon, 13 May 2019 08:51:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557762678; cv=none;
        d=google.com; s=arc-20160816;
        b=jbO/M1zrPZFE/I2vz9+ZdkMv7gyvszSICBynTmU4nnEFX2XfbCa/N9VLUAg0yQSQLC
         Nq/rfSHnJ9ff7xmiGROVy4F7BeRxbEqzL76uGwaOLuMUepYSHaMCiwsh2L1k7dquL+wx
         2qAV/+0GVd1d/m03tHdvcD+6xQl8Apy4lZDHDR9gVeClEHuK2EntuNZtEvTr0WLqWt0o
         1HaRd9tgi8mVtCRaxepxLgvcjpMnp8AScnkXR0NRjZq0/9rX7Cjwyv6sVktkRQErQVhj
         pujYwq14Vex2V3QYs/huhB8tpqM7iT6195ubpxllF+MT2tCIwfLXo7DPZcP91XWc28O+
         n7oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ORppQGlcfBf3WPuXFmYvQJ48TDHuiN6acZ7PdcalqYE=;
        b=SnbNtOCgCAZi8JgyYP0P2q94k0yiQRV443ptz+6tAtNU3pY9T0im47sFHUzf4iddID
         iUbliArgGobYlWIfUYFSn3KFDM2ivDg5QeusFOUa2yGaRjT49YKBL8pD0JW3Cr+OtG+T
         fZiVhzyBQj2c3u9TVAjvGamqq2AV3KhvcwDkbwdmsuTiFgaK9Mmml+eyzI85r9UFOtSN
         9Gp6Wxv3HX8STG+NbBZkbjaxhiJNbOEaQlIWhfd0m47tlKmEQibPEmZDI8Zljv+Ds9oI
         he6gLnwCgpe6NLrKOWJ05JEguUz5K4/k8Hn5A+qzCpfdyTOt5/aIcsXp7P+1L9dJAjz0
         +ZeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fyu+eEyt;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p8si16521549pgc.362.2019.05.13.08.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:51:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fyu+eEyt;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F2FFD21707
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:51:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557762678;
	bh=VO5BWtK/NhFMUgfePe27x1pllPiG08W6xyS+rnVVOZ8=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=fyu+eEytsVWPHDXWOsfR/TJPqHCmbiYlK1Fnjgm+jpYglv6rVvm/+qXEvZm5ZT01+
	 Y5BbMjwW0+hAE1oCsSINHifec3q/3FiaUs/zGMRfMHVEN4gqXnxNhy75utPulzWWZm
	 sbdTaN4z+XaFRnmavwNqVm51mR8QZNfjMl4l8AIg=
Received: by mail-wr1-f53.google.com with SMTP id h4so15885598wre.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:51:17 -0700 (PDT)
X-Received: by 2002:adf:ec42:: with SMTP id w2mr17344670wrn.77.1557762676520;
 Mon, 13 May 2019 08:51:16 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-7-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-7-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 08:51:04 -0700
X-Gmail-Original-Message-ID: <CALCETrUzAjUFGd=xZRmCbyLfvDgC_WbPYyXB=OznwTkcV-PKNw@mail.gmail.com>
Message-ID: <CALCETrUzAjUFGd=xZRmCbyLfvDgC_WbPYyXB=OznwTkcV-PKNw@mail.gmail.com>
Subject: Re: [RFC KVM 06/27] KVM: x86: Exit KVM isolation on IRQ entry
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>, 
	X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
> From: Liran Alon <liran.alon@oracle.com>
>
> Next commits will change most of KVM #VMExit handlers to run
> in KVM isolated address space. Any interrupt handler raised
> during execution in KVM address space needs to switch back
> to host address space.
>
> This patch makes sure that IRQ handlers will run in full
> host address space instead of KVM isolated address space.

IMO this needs to be somewhere a lot more central.  What about NMI and
MCE?  Or async page faults?  Or any other entry?

--Andy

