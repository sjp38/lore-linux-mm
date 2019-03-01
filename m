Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B48BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C18CE2083E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:47:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="hGSWBt9c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C18CE2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 719298E0003; Fri,  1 Mar 2019 16:47:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CA4C8E0001; Fri,  1 Mar 2019 16:47:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B99D8E0003; Fri,  1 Mar 2019 16:47:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA0E8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 16:47:22 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id j10so16469007pfn.13
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 13:47:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QLCw7MLhv4h+6kZHr+YJjXn0K/KcoNEB426LxMvC9t4=;
        b=g/5JVphCgyLy9KNMscZwYlALaEtCFksQVwMTCWDeVw48eM0+MUJtcZak5jNwy0iA/m
         YwofgVGP4KmMO8nUA3N3LqN98uTmqPTwD0q7XEBZkFgTs7nahsKBiYbz+A21y3dpgPKl
         BPzE08sBQE7rym2pyn6AB2M/cwyJsiA5k4LWs+dviVC22sQpagL1Lfuko3HlCYayMVeg
         +EgnijDtCJSjeK3U/vykyeuWhwX14kbWvH/99ROjUSkxRm/450z7xHkjJZHDfHsFCJQQ
         wBwqSaRjMp/hxoUOgrTURWBXGIwgwvIVOuC4MyavTfrYQEHVePFVl0qSxLkPXBuCdgc0
         fLQw==
X-Gm-Message-State: APjAAAXUvdK7+3ctBlI1Px62Myn3exno6/zqiA/pejaN037UZi6VjXae
	27QdQVLkCrHw0ShgcKG1CWZyK47N4zXQpk9QN2aNmWbs2eU6FuAe2uorn3d8mLlYXsOO26lvXMe
	lcCu2Ru+An/Szn5yJbwz/ViapMsQWAYYkUH3O1lDTXYtmHg+z6A2u9u/JPtqV1yhSe1Mh/21yhB
	biT+0kgqEIw618GulHgL43Q3pNLSHsDVkxY5A+HNwOyMYQ7J6AVnD0vM2zUKJUri3jzGG9QbB1C
	RYua4u0JEalQyOpxT2lMDd0CXAw1rx2QJHdXSe464p0oVqpS69emqRu3ZnNXFvkUyl7oehmBHe+
	hi6KB5FJMdpXtZk/9v/iv7c6bqACuLyQ9brVE8zNlyJoXPiIkKtenaE5jczBDOHr2hKpVBIlMci
	r
X-Received: by 2002:a17:902:a414:: with SMTP id p20mr7531759plq.289.1551476841662;
        Fri, 01 Mar 2019 13:47:21 -0800 (PST)
X-Received: by 2002:a17:902:a414:: with SMTP id p20mr7531710plq.289.1551476840747;
        Fri, 01 Mar 2019 13:47:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551476840; cv=none;
        d=google.com; s=arc-20160816;
        b=ujnxz2qlilniPmhHofRN6khh0DOJa5haDViNdFVkV+iWVgTtAA4rKkePuo053foLkg
         41r8Ue7ib5uMI6q41JmSiOnqNOarP5cc1rvnhn8p/tavy9U3naZ+jER4gp/SkaGDvnSZ
         V/eaqyKPYgZEtymfP54uxK61QyIBar+AcBKrnueNkJ8myPMtHOvF95TMdHzUOxIQbL0D
         F6aqhGG79PggIt6Ly2KyRkF+OsDgvgR8GnMqW4uRsWrXjJJIqCgAc7mQY5XQIXEGccR6
         EgjyVRX67vVaRZ6Oc8LbMKnIAprfk0VYiuecVSz2Tnuc8xnNIwEZngXWlRomi2DK//je
         4lqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QLCw7MLhv4h+6kZHr+YJjXn0K/KcoNEB426LxMvC9t4=;
        b=tGvc3Eeeg2A3zoHq5GEZ6TUbRD0Yse9DirGmbmfvSSVe42QdszxOP4TQiWN/Mna1RU
         C1cpgZ3ZRBnjEYD4n/U7M6xhXi3pHYpwfxq/nVYQrybjPkdhNxnA8ww0HMTbEWOXG5En
         s7MofmCylQuanQ9zAyfIErzYjBatUk8EVcxWglfBtYVSASRIwNqeJsVjALT7M7yRf9oX
         yuNjg8jBAwYgut9uR1kOXzr7spjr3MYTSWtJHbxybjjQlmp3kFVaXZgfHHBTxNCijDLm
         eYwnr1TwmZWS9sGgSQC0bcyX3a9KlCA4UChdqLNne9sa56oj4dvOX6Hwd7IcSWpR5Q74
         LnoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=hGSWBt9c;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t124sor35858050pgb.63.2019.03.01.13.47.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 13:47:20 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=hGSWBt9c;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QLCw7MLhv4h+6kZHr+YJjXn0K/KcoNEB426LxMvC9t4=;
        b=hGSWBt9cAdoYKR8uVW3ACUTxEx7wtlE60eK1bM2uTil9ubZCqf1Wf4S344xhrLinwn
         arwPrWLf+QkEgzLfkeRh3iRLMq4wHabZSRbd2FHG63IJve9loprZQw6hIVrrlYyenA6N
         iY/Jgo/gd+Bqq1dHmKaUB4U9WOSUra/Ub86v+r0lIsJWUe3nTXYixZnvjvg1OkZcvDCz
         HHl/8kmucKICv41ZcYbQ5MPuOLF9cLjBHgCE5BBKhVroNkG0Lg/d3d4qSfNJGH5M+N6a
         /eRdV+kYHzMGV2ip20Wsx7EWopJCbw9dyBrSiRDn6Eh/DvIdyY6cDUvtMZKnknv1JMJR
         AMyw==
X-Google-Smtp-Source: APXvYqzRjAIshow/vWlG/VpbnTSdya8ANavzF7Zh8+rWVITXx71CANEIMI3B9wQRqGWL9XMWXcSzsQ==
X-Received: by 2002:a65:46cd:: with SMTP id n13mr6894716pgr.221.1551476840156;
        Fri, 01 Mar 2019 13:47:20 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.82])
        by smtp.gmail.com with ESMTPSA id g3sm30177184pfo.125.2019.03.01.13.47.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 13:47:19 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id C391F3007CA; Sat,  2 Mar 2019 00:47:15 +0300 (+03)
Date: Sat, 2 Mar 2019 00:47:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Russell King <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 03/34] arm: mm: Add p?d_large() definitions
Message-ID: <20190301214715.hyzy5tevvwgki4w5@kshutemo-mobl1>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-4-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227170608.27963-4-steven.price@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 05:05:37PM +0000, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information will be provided by the
> p?d_large() functions/macros.
> 
> For arm, we already provide most p?d_large() macros. Add a stub for PUD
> as we don't have huge pages at that level.

We do not have PUD for 2- and 3-level paging. Macros from generic header
should cover it, shouldn't it?

-- 
 Kirill A. Shutemov

