Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1655C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:36:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFDD32726D
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:36:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFDD32726D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FA5F6B000A; Mon,  3 Jun 2019 11:36:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D2516B000C; Mon,  3 Jun 2019 11:36:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C11B6B000D; Mon,  3 Jun 2019 11:36:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DEA9F6B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 11:36:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so27981383edi.13
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 08:36:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fYwLv/OPaFFLJCaq1inFKv5PGV5/nINbA86yc/EkXE0=;
        b=sv8gvg0gykHr4oAixG72eE4JVdyG6goxo/SALUcjvjhn44kPsMX7B12CwoOqvSI+Yi
         OxAhkLVxwGzClsKqh31pmbg6zVRIze9DnJFLGGHNgCxc3mtt6z7VoyABLV74GGKAzZQ3
         dTmE6maZuCGbYExRX/3kmYgaq41JnjoxjduWwJWMosG9dTJiLqwXdxlT8bTkYlyk3vhq
         PVaniv+XPNaGiQ4Fz8vZdgGUezfAu3qviyvCvdU/UHeoeIHpfRoLhMYEY/joWvqx5TbR
         oevMXsnUzoteHuNMgOE6lMrxDRIKU2+uHvzBOS42/U+4Rj6MwxhaIdxL4yeV9T1EFiNu
         aR4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXV1bhX66hp5DrtUOVeDQLtroRVmvc0Y7YA8JAFKcgCZu0xrilE
	EmVfNyeCgb/pgIsEx6UZwp3HBJjMc+oMUwSThcVZCIS6D53Q28IM+UlN/OUDvR1Ii+ziL3D+t5+
	YLtOz301KrAu3Ald0qh2Jrdi1MJ7X1kWBCbTLbkPUNLp+7gSLr5nvSC/sSCu/w/2V1Q==
X-Received: by 2002:a17:906:830d:: with SMTP id j13mr23878156ejx.151.1559576204358;
        Mon, 03 Jun 2019 08:36:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz99+3q8Io59Z+ZSRgaa1TG+R9D9ulvt7B5ShmQfkwfWnrMxuEone9oHDWp/H4YYDWOX/MD
X-Received: by 2002:a17:906:830d:: with SMTP id j13mr23878079ejx.151.1559576203380;
        Mon, 03 Jun 2019 08:36:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559576203; cv=none;
        d=google.com; s=arc-20160816;
        b=SKO7fW6Ua8aYtud8Jeq/VQjlBCBv9b1iw07RsX1dIJpowbJiPJJg5IvyGVc2k4o8nz
         JNIeyTqLI2pZm3MYnTywmFwpD4+zA+hnWcUD0TGUaSn3KPPGeT22sGYuTogLB0B2Y/4l
         E1qtc6mZ6zbxH+LORTue01qfNiUC+HNOxdF5Ukm5i8+WeUgHpIsG4ynYhk4SHixls7qu
         MXc1RB/OnkO3vXcBstUoTWmO7KkNw+iX5R7L7VbGGc/7oHZHZyJUk8n9ftetq1hkPz4Z
         0XnFlde1O1Cshmo5PhN79LIdS+JW40bpR74pjEBCX3PJ4Rm37Aw0uPsnqnMCy/wU5r1U
         uOIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fYwLv/OPaFFLJCaq1inFKv5PGV5/nINbA86yc/EkXE0=;
        b=QD06prPwOzTL1YxgC6gjRkeoU7vEodKy4szfOOxOtov0q4qORMrvt8McCpc6uSsdrb
         Gf3TV6W4uh1l22mFzPbjAGkGyGjrYdRsDZ1b6kD0dgdfwUIwnPTV3/PT4FlVOj2j4Lwh
         sep8GuOAr/HQM+BkjQdGDI3oq2M1UcxspIRSrv+6u2Id9TpwOIvQigk41p/pFnM3WW/2
         iIp6H9dF1QjwP7jIHJsBFMReUTIznbovHxfkcBhQFI3/jbjNvBbJ3Sm0jHfkh1klPGPp
         uWouHxWJB6I10Yp1qf0/gtwa7ZtDtaURMWoBmZZ6+dmDQ7IpE0cpx6fFFRmc9RFwmLGC
         Fd+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id rk1si9680028ejb.105.2019.06.03.08.36.43
        for <linux-mm@kvack.org>;
        Mon, 03 Jun 2019 08:36:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 55C4380D;
	Mon,  3 Jun 2019 08:36:42 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F37BE3F246;
	Mon,  3 Jun 2019 08:36:40 -0700 (PDT)
Date: Mon, 3 Jun 2019 16:36:38 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>,
	Robin Murphy <robin.murphy@arm.com>
Subject: Re: [PATCH V3 2/2] arm64/mm: Change offset base address in
 [pud|pmd]_free_[pmd|pte]_page()
Message-ID: <20190603153638.GA63283@arrakis.emea.arm.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
 <1557377177-20695-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557377177-20695-3-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,


On Thu, May 09, 2019 at 10:16:17AM +0530, Anshuman Khandual wrote:
> Pgtable page address can be fetched with [pmd|pte]_offset_[kernel] if input
> address is PMD_SIZE or PTE_SIZE aligned. Input address is now guaranteed to
> be aligned, hence fetched pgtable page address is always correct. But using
> 0UL as offset base address has been a standard practice across platforms.
> It also makes more sense as it isolates pgtable page address computation
> from input virtual address alignment. This does not change functionality.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: James Morse <james.morse@arm.com>
> Cc: Robin Murphy <robin.murphy@arm.com>

What's the plan with this small series? I didn't find a v5 (unless I
deleted it by mistake). I can queue this patch through the arm64 tree or
they can both go in via the mm tree.

-- 
Catalin

