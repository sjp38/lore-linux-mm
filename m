Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87E34C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:57:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EDD020840
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:57:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="VWCIfWP2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EDD020840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D04B18E0003; Fri,  1 Mar 2019 16:57:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB4068E0001; Fri,  1 Mar 2019 16:57:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7B7B8E0003; Fri,  1 Mar 2019 16:57:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7864B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 16:57:34 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id n24so18602453pgm.17
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 13:57:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Jx3z/ytyz5m19uf5/3OhEnIdJ4HeALh1pApg6ERgUjQ=;
        b=ovjeeukOBGY+8VwDbHw9x3iFpH6Tb4+JAwCzwcMiuoDPzbG4TbZjuweap/2WFYQnvn
         v593slYwJtsV+Pv0BZRCOtJ9z+Q2fzqD2vYNi4ISbsbQAWVMZ61SabFS1pa4VDyhJPU1
         Ujk6UOy9SZEN0sXKSzLXi840HvUdWz0sMVGy38FP7qDhRoRb0a3GZ9GGQtp/rOgeWcgK
         eYWWxyIWm43aBZW+tmaoEeKoFdbZcBlyWP9RiJZEczY+rnNw3S4ChicxcEvelQ6MnDd3
         eI0SJN0TMLSPs4fPo1lywldcAsYXxD3LRRBEFJRlow0ILsW+BzoG5jPKpL2bQr/DXuy6
         ILgg==
X-Gm-Message-State: APjAAAV5Kd3z7q5mpHI0KRB8CD/xkNKJtWbKKqr7EB5UVnESbmQK6X3V
	Um+yih79mZF0R3XzHBT35XuS24ZkX6rwIuMIgQ28g4ySsQGqCWIqdHvZF5gVNvLQ5e1QQ49E/bq
	76m+21XfrezXckGngMkvoMy06pEPz5Dw7J8DM8KlUqPFUHL5WvRY3pV+KLT1WttTVTF8TFRWXp9
	e7vXffpX3w73b6vbeOu8NrzIjPv4bDxZZip0q3crNdMhx0MiLUaqM5w9/1WHJTIJJv6v1K9xO43
	vmbzpmD0R1RAN31tabd/DDO5he5UbyTU6RncCpvzx1JOH+t/V11aHcsJTbrdkLbuggN1Yu1Hs9M
	86S7IXEOMX2V6suY+31dPxtqrSxngFvgHKFZbonUEs2G6rcpnsRp/Lgh8uirszntEA6nhI4qn39
	7
X-Received: by 2002:a17:902:7c8f:: with SMTP id y15mr7680071pll.44.1551477454185;
        Fri, 01 Mar 2019 13:57:34 -0800 (PST)
X-Received: by 2002:a17:902:7c8f:: with SMTP id y15mr7680023pll.44.1551477453293;
        Fri, 01 Mar 2019 13:57:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551477453; cv=none;
        d=google.com; s=arc-20160816;
        b=eAoM7oDAA4tFCxm6N+OCUpHYnYkOnvPr1PToAxR7kmkuu1J8xXFRPPQ7a4BOqUW4h+
         YDbXjPXWy2vLLMokCOP1YcSVsRG8d0w02Uict/hinUhTmq0rGGgokCkclmfWuNRbyoj0
         2hXnOGy2WSTWrc+By9L8sS0L55UhHxciFVXu+qUP0qtPSjEsoUS4ufKFmsOLInuVLd1Z
         DaVXlkLhv4HAV4YgpQ7XrDnzxkJJpDo7fNjwsqVX8nycctt8Chf7AO91EWqGHIZd9mSi
         qYQkhc/Um+9t1EAzSB7NRECcK7oeVOkGLIgUDmAq7sCyT9Pk09y1f718Y0R+jOGoTFjQ
         W9Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Jx3z/ytyz5m19uf5/3OhEnIdJ4HeALh1pApg6ERgUjQ=;
        b=ZeFhkehY/EuU1UUb4B3WMOmxjxUYkmR0T9haCwM+l6PekeWVh2wnJBzSa4Gh5f/6dP
         VZx5foiZx9ZAlPXW2ztF5VkK9TNXh3Q8gQYuu195Lanejecx5fi//odu6JsWfTdrJ3mR
         4Vmpj1HEHOOj1Q14b2F5yDmgZo/q75MifIk3d9+dstApH1c9c7kF8qgDZUCiYAfaAG4f
         UpHRBCoU5LaEJp9YTetuJasdWZ0OLmWELLuLFNQoBoLBlHj7EOs7hqQKhfkKowovPR6h
         JmxyRofqZOBceiC5JPBSVxOhbHJ3auwgO26KaIQcRuBG85dr0uHVqoJZV6d2hKpjLPN0
         7vkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=VWCIfWP2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor34569756pll.50.2019.03.01.13.57.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 13:57:33 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=VWCIfWP2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Jx3z/ytyz5m19uf5/3OhEnIdJ4HeALh1pApg6ERgUjQ=;
        b=VWCIfWP27qc4osBHSUj5kLtCbj1ntVG+T4U8cTziGn3o5lyIecEuKchHhsbnqL+CwA
         13YMR2ZMV7TGE1fULeo/DFlO8tnOmgddd8Pf9Ah2yxBmTgTuxFIuJfYCzPIJHD2cXTnO
         Qqak5FoFfvofzU+xzZijTG3UsxrKz5JVFvIgBNUqxH2Pj1LvDc/JGatqsqlqIk/aCh1M
         MoFY+8OhY3uy8AhjCMqOxtlMiN0zGyZDV6+oOJVShbNAs7Oy2DEe3uUvT7ck+CK5Su7b
         68NTf+tY2uHldMNd5Gtkp7V5WTaz0lxFiMGKLvUyWIS/BHQU3bC/H4sIF36rozN6FoGJ
         mJOA==
X-Google-Smtp-Source: APXvYqynodEY5jKFUK2x2PS4hoYz1An80WXto1OjEKBWf+zdX8l5qOU4JRwZr0ket6b24/Q9y39L3w==
X-Received: by 2002:a17:902:12e:: with SMTP id 43mr7841762plb.31.1551477452908;
        Fri, 01 Mar 2019 13:57:32 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.82])
        by smtp.gmail.com with ESMTPSA id u14sm23818699pfm.66.2019.03.01.13.57.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 13:57:32 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id ADD193007CA; Sat,  2 Mar 2019 00:57:28 +0300 (+03)
Date: Sat, 2 Mar 2019 00:57:28 +0300
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
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
	linux-ia64@vger.kernel.org
Subject: Re: [PATCH v3 08/34] ia64: mm: Add p?d_large() definitions
Message-ID: <20190301215728.nk7466zohdlgelcb@kshutemo-mobl1>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-9-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227170608.27963-9-steven.price@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 05:05:42PM +0000, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For ia64 leaf entries are always at the lowest level, so implement
> stubs returning 0.

Are you sure about this? I see pte_mkhuge defined for ia64 and Kconfig
contains hugetlb references.

-- 
 Kirill A. Shutemov

