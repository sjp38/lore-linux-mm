Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A621EC10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63C622077B
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:16:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="X9N2wtn6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63C622077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FFB18E0002; Thu, 14 Feb 2019 11:16:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287198E0001; Thu, 14 Feb 2019 11:16:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 129E78E0002; Thu, 14 Feb 2019 11:16:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF3168E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:15:59 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id s5so2401284wrp.17
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:15:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nRzGo2WdRGVlfCrR5IW3r6niSjb+gE5vLdPAiNJgD2c=;
        b=nKU01rlF9qwGPiATzFOeTkE6tgFuHDomoOE59rU5+2ZJtFHvnd2JiqIcuzXh22uISM
         h4erI1YHKWtMX5rUF6WCULKaK4NvQ+rurbVZTIrWI6Yxen3d4KBzVfO694XuWBTymQHi
         Rew2jTcPc5d2/1mhlsCtoELVBAUKsb3hkueLuuPepoI2/AzeloFqk/qaIpA8cxxewrtz
         uoQzvTnrWDQpBENE2w6kUGkIzSo6ur3yrjB/si/Ydc/dXng8Imzn2HfyjJGaWi0f/g4V
         KYDJN1Z3Cqz2kSMg1otqtBK/O5PNWdiQ0rSj8gPWZZm/ajN+4KVcTzSd0H1xappg+6Px
         uFTQ==
X-Gm-Message-State: AHQUAuYKjjoW7R/dLD3UE/xy4yaca1X0MsYqsQu3WgiZHgkIhdS++kQL
	jhgbxcxbU5mOxMCU4rSHdLj1napYLG7QX+2aimPRPUXd4KNhf0+LwHpDQlgVJl5siIPnnnKNHAu
	nBQnOvTvFa/kaqhRgTSuQ2LatpHJqszQx341si8eEpWP0gBqmfVAx0xxEd3Asn0ZHWg==
X-Received: by 2002:a1c:c010:: with SMTP id q16mr1560794wmf.134.1550160959263;
        Thu, 14 Feb 2019 08:15:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBXBktQydHy9/oV/VtKIZzO1HNP/PY2w/f8x2bjIZ7si2eR78SsZOeq6iTuqKRwboZqawO
X-Received: by 2002:a1c:c010:: with SMTP id q16mr1560747wmf.134.1550160958411;
        Thu, 14 Feb 2019 08:15:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550160958; cv=none;
        d=google.com; s=arc-20160816;
        b=qLiTym9ZyHfr0VnUT94nKP+krh3JJYhg2nGU6l5fsxN5hQ+NWJI73Xk4ySWmFb7tNv
         NM81Cx/kxRWacaLpyHNAcJu+1hAGj/JPas39SL0q5oGzKp2SzMagIEAVdVxnBFQXNpmp
         hv1nAoSbG/zd1RkKl3RJa7h1Ejr436o83VtHUv5DnFVLKc4DDGW0aW8hFNmql/E2P42Z
         y7vxG7QtbxtzWqiu87KW8fLdKUamUk3rri1Oxu+19t6WNOBlVzw2ARPiktvYYzE2uXfA
         0j+0IXg6yIWpaLsTZirAYkoHjvj47jJ9hO5/DP/ICo/XksRQYeeviCKEbmy5ulrstIuM
         Ld9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nRzGo2WdRGVlfCrR5IW3r6niSjb+gE5vLdPAiNJgD2c=;
        b=tl03ALRuhBpH/jRaHuS7tWwulHwkgDgUKfyngdtaJPLx2NS1qMisyJ8mzJZ14irHIs
         6cXglblwxTF+R8wCrALuZOwCjviw5tu3jMgK/8BUOBoumZCQQPPjcnilg2VxFVVaYVm+
         kf7P4WrG8VnxbAIhzO00xzBeckYO0rZ5c9yY75QEd5vf6vSRp7kBUQln2mIDIb49LNTb
         rKOAX4Q1odQ9bFTfJ8uRW5o7U3+TyqC1Oiajfo50NXYGdk3PjlAs6K3Ha6BnbYkkzCcM
         tak62t6WA8a8ONyS5ST+kjfF7/QyAH3XScPSaP+q6++6cnFZZWlDYhGv2pEFWa5Ccrjf
         1KFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=X9N2wtn6;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id j34si1914448wre.310.2019.02.14.08.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 08:15:58 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=X9N2wtn6;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCDFC001CE8649D49136343.dip0.t-ipconnect.de [IPv6:2003:ec:2bcd:fc00:1ce8:649d:4913:6343])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 11D161EC0253;
	Thu, 14 Feb 2019 17:15:57 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1550160957;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=nRzGo2WdRGVlfCrR5IW3r6niSjb+gE5vLdPAiNJgD2c=;
	b=X9N2wtn6f0+HrkqlYxsrPU1T4BUJXTu6UuzwxZwPNn+jFGABVXEN4BN5WClF+wGi1DxAQq
	E/Rvm4hnd4jV3rJSqgqbAXFSHNsWcXRoVTe1Ju+cvwu5Lugv3hoDPrpvlrXJiHO4y4eoFV
	P1NBzIFEoRdA87/zavwJ2qWiX1cCQrQ=
Date: Thu, 14 Feb 2019 17:15:52 +0100
From: Borislav Petkov <bp@alien8.de>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, tycho@tycho.ws,
	jsteckli@amazon.de, ak@linux.intel.com,
	torvalds@linux-foundation.org, liran.alon@oracle.com,
	keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
	catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
	konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Tycho Andersen <tycho@docker.com>,
	Marco Benatto <marco.antonio.780@gmail.com>
Subject: Re: [RFC PATCH v8 03/14] mm, x86: Add support for eXclusive Page
 Frame Ownership (XPFO)
Message-ID: <20190214161552.GF4423@zn.tnic>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <8275de2a7e6b72d19b1cd2ec5d71a42c2c7dd6c5.1550088114.git.khalid.aziz@oracle.com>
 <20190214105631.GJ32494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190214105631.GJ32494@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 11:56:31AM +0100, Peter Zijlstra wrote:
> > +EXPORT_SYMBOL(xpfo_kunmap);
> 
> And these here things are most definitely not IRQ-safe.

Should also be EXPORT_SYMBOL_GPL.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

