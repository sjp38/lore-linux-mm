Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 382ACC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:11:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC1AD2075B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:11:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="N8cidJa+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC1AD2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C6E38E0004; Mon,  4 Mar 2019 08:11:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8774A8E0001; Mon,  4 Mar 2019 08:11:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78EF18E0004; Mon,  4 Mar 2019 08:11:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 343098E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 08:11:19 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o24so4825204pgh.5
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 05:11:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0mz8hR/PW+TukAB77KzXlPfAhIvUFB5c4A/6VIejvxk=;
        b=nTxcxfWicIFXhNwvBNKO47ZJiUp0kCSxsot7fU4YmDLQmrAKVqy89s2uvcTwA90Kcb
         ATrIZybOErWfWKNBK7kfQ5SPInAEa0njMabmHztTzKpfbOYDc66fy6Tcd/qTJeHvj1TF
         U7ORtoyUy/axmTL4N7c3zeBEFq+DTi2vJI9uXXgZdbRRQVzwpPcHffWF0gPKEK5ob7Ry
         NT04X3OaCx/NYwLa4sL8iVFjdAxgeMkgUYtR2eZwpzH0vGhn1rvwsB7BUtTL1JY4Y+SP
         EwzNZB2tKjyFlLqsVES/ZHYq4DtEiA6Fjczow2iJKb+RiCC2ZzjBwG/h86tsASe5ZcW7
         NClg==
X-Gm-Message-State: APjAAAXgFOo13VG1ndoTe9vi025/XO77h8edwVIDsGyNCXe93R2Dd3w1
	cJIPDXn7UkAUSdaHBnDS9p2zfrkzuLCE+mj+IqDDSyhIDhVcPkd7ueDtLmW+HyQ7BV6xUCiq0GU
	Cm6eMpFmtxC0NIVHI9mFSYs5Ie7jP/1Xg3dRHAzZmju4LJjGtf6TC5yqn0sbEU/keY74IWz4diX
	bKjg2jirRDXhoO8zeazkj4YVq1B8h61BSPB+Q4cdwbqxlyF3Acj3WLRL99stk8hWTEuN3lFrtp6
	pKy0M4PyVk0vpxojv9e7Ix8MEPpVBX21/0/aBBGWZ40Fm5RXWzBYtM2A2sfW+UtbOt3AF2mLinj
	wLc4TGpJ/obddBt/BnXv1DmXfzEbIy1frftRsJbT24iNJqIDDmBkBNYMV8PxXCORQ7KXQ2dQkSr
	l
X-Received: by 2002:a17:902:76c8:: with SMTP id j8mr10724733plt.18.1551705078912;
        Mon, 04 Mar 2019 05:11:18 -0800 (PST)
X-Received: by 2002:a17:902:76c8:: with SMTP id j8mr10724677plt.18.1551705078254;
        Mon, 04 Mar 2019 05:11:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551705078; cv=none;
        d=google.com; s=arc-20160816;
        b=fMhFsCV2zgfCjJbiYoZz5ezd3svzRxjYL+xK9CgR9D5altnMnv8VLgE/KcUYWfFu+0
         LVqzpdrt4bqp2EJVrfZMAlBRggdpzkTUv0VHsq091+y36pDDxI46Mzqy3A8Us/IzDzfw
         GnGG6uO6RJb7ZtUl6Xc2jkwbAzoLQyUH+naiVgMiAQhiZaJl3ydp7/zYGMiVRAlrySLl
         cPDIKa6zZUZiXl+HV/ItFSUQREyg99SWmM3M9Yy54xWdIlgOg40diIuCULVISMChSOsZ
         zpyp0yF4eMdkMcy85MNmdkrYb2TsEDNWDJLSj4om/Rr7zVVij2cUb1OmU9b5Cz8y8fXv
         MK2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0mz8hR/PW+TukAB77KzXlPfAhIvUFB5c4A/6VIejvxk=;
        b=JqSotwCtripdkdRoi+pV00BA6QO84PvBEb81VXdR4e/meofa8Go9UE30Jq/SwTnVPE
         0GQrt2DJO7YKfWtg3PO7dKHIY1wbtDclZ9DHl/0hfjjz4scHxxkhQ3OXebpgKzvZ9oGp
         P8oT52QGtFiWxxtsmWzhkxTCYukGKoEg8eU/tQCWIXdL2Sw75ZmEg+WsYIl4dS40SDVE
         DYiGoFEcIEjVWJESVietvUENwAC8Nc6q/hw/BXuFKIlMHKIs0s8GsMzV/fjBu7cExjdW
         ZPJvQiBtL7Nx3Id1wZX37Ef4WhTMH/L/37CHyGNisHIbNOfZTgM4CmxyWNkwBHHmOWxv
         xK4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=N8cidJa+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w190sor8658211pgd.67.2019.03.04.05.11.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 05:11:18 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=N8cidJa+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0mz8hR/PW+TukAB77KzXlPfAhIvUFB5c4A/6VIejvxk=;
        b=N8cidJa+RBPGSL+FpF/dmOQUuLI1A9v0JjWx4C3aX+xibANTueBDzft2D+a3cvEHdu
         ZBbZPzSMgIcHuBY8biFXoXeJo85Qodj1KzLd5RsEJda/rl8QB/jcFckZllQYBND4I9db
         IFXv1KogTJk3/eGYvqccL6WziE2Oz9xj/ktRqxWvtARahwOh22wYKWaseQ5OqyzEDi3q
         z/To1xy/WMuTBcGyGNxUp5sWGAJS7/dBCr2ouCq0CXGRFzkC5eySyZKUYSVGNxzhnE6O
         jV25/GxjZcafM4uCvTHkUX1FvmvZ8UHrqXoAdE6HGE/cfws19vborK26vWJlV9v2XcpR
         OguQ==
X-Google-Smtp-Source: APXvYqzAWJ2k3k7IQ3uno9qOI/nhQp7EloMYKyZOcYGMZpgzNkdiqKlyXi09LWDL4bNZVmSSr/me3Q==
X-Received: by 2002:a65:620f:: with SMTP id d15mr18557884pgv.112.1551705077993;
        Mon, 04 Mar 2019 05:11:17 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.40])
        by smtp.gmail.com with ESMTPSA id v6sm8704444pgb.2.2019.03.04.05.11.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 05:11:17 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 0B911300429; Mon,  4 Mar 2019 16:11:14 +0300 (+03)
Date: Mon, 4 Mar 2019 16:11:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	linux-c6x-dev@linux-c6x.org, x86@kernel.org,
	Ingo Molnar <mingo@redhat.com>, Mark Salter <msalter@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Aurelien Jacquiot <jacquiot.aurelien@gmail.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	linux-kernel@vger.kernel.org, James Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 05/34] c6x: mm: Add p?d_large() definitions
Message-ID: <20190304131113.qlf4bs7to77wm3ui@kshutemo-mobl1>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-6-steven.price@arm.com>
 <20190301214851.ucems2icwt64iabx@kshutemo-mobl1>
 <f840db0e-bbb3-db7e-d883-79b5a630767c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f840db0e-bbb3-db7e-d883-79b5a630767c@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 12:01:37PM +0000, Steven Price wrote:
> On 01/03/2019 21:48, Kirill A. Shutemov wrote:
> > On Wed, Feb 27, 2019 at 05:05:39PM +0000, Steven Price wrote:
> >> walk_page_range() is going to be allowed to walk page tables other than
> >> those of user space. For this it needs to know when it has reached a
> >> 'leaf' entry in the page tables. This information is provided by the
> >> p?d_large() functions/macros.
> >>
> >> For c6x there's no MMU so there's never a large page, so just add stubs.
> > 
> > Other option would be to provide the stubs via generic headers form !MMU.
> > 
> 
> I agree that could be done, but equally the definitions of
> p?d_present/p?d_none/p?d_bad etc could be provided by a generic header
> for !MMU but currently are not. It makes sense to keep the p?d_large
> definitions next to the others.
> 
> I'd prefer to stick with a (relatively) small change here - it's already
> quite a long series! But this is certainly something that could be
> tidied up for !MMU archs.

Agreed.

-- 
 Kirill A. Shutemov

