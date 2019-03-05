Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C627C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:16:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4E19205F4
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4E19205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03F548E0003; Tue,  5 Mar 2019 16:16:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F08C18E0001; Tue,  5 Mar 2019 16:16:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DABF08E0003; Tue,  5 Mar 2019 16:16:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 998458E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 16:16:46 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h15so10780759pfj.22
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 13:16:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bW8ImPyWYkqRlGFXBHr5QyjY43Bs1+Zz3QCbHLGpdic=;
        b=BClA5All7rkcdabwMOT0/jD0C2RrgNqbHrWCxOJoPyDC7a3oRQhOhDw01DHvkUB9eq
         rhBkLHFFXnXLa4lPUAAAD4/0hFOQctSYM6Iii5HRBNquGmJEyiAEJdqwcDZIAfBLW1NO
         SQ+yzbPckv6R21gSY6Bi0XBS3zo0CgG87WF/UzZAW84c+92C9L2bosF/8cC1Xf3Ld+EO
         HrrDleD6d5p4bBkClEOjgEeMwfUBUrC+elmzczxnmS9M6zo/PM9oy47wvrSDFJaRnmXf
         6kiO+cwN/j4rti29gFo4lUxUjwUU8cZRjYufBZTyiDIb2clo4LHD974DaN1XtgDKN63m
         P0Gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVGuuPyV/HEIAXp9s18pew4VlccS3KX3tBOT3d9jgFCY14W/AML
	+fE7wiEcF9TSxrqb1+JHmMSXT10kp44zz4OVhaxOoHs1NpJkRVthNcahZHBvfn7rRbG28NHswbL
	GJjNGEXShPhO20zv5DYvCF7JunAP+exqgNnBUlbuFurcIDzloc1JCwLERFpL7+plIug==
X-Received: by 2002:a62:76d4:: with SMTP id r203mr3844819pfc.15.1551820606250;
        Tue, 05 Mar 2019 13:16:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqwagOazJkODxvz9gFVriKiLGwBPJHhb91icvmJsrEgoNgu8lj8+wSwJZ+N0gDHI8N0t5t1w
X-Received: by 2002:a62:76d4:: with SMTP id r203mr3844759pfc.15.1551820605238;
        Tue, 05 Mar 2019 13:16:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551820605; cv=none;
        d=google.com; s=arc-20160816;
        b=jRooIJyKsI8ms360M2lS4U1eseuCLAK/2LPwPY+A6Jt55/XCyfOYsiz3hVXpwV7xQ5
         KRnwHozc//YJK/UoVJ/Y/KMRGhSdSS6Mln+joFKfuKM2jTOW75KqFjz6vySPAeMQ7cCc
         hpw7Roo9MDfOimXDGgoQ0hWO4WMuIk1sSDiSJjm8/w1Ja4nQe0aUuHLgLnhiwCtN20J0
         MSr1YJHAeEgtK5M0EV+Ut0X/xXHwMr6zhx2lZD6IkjY44xmCTglZboIAXAZ4AincSYka
         fOwoD4kPTokMfsj4zLfcBdxyFFwHlWw06oSH+gH6J4cLcE33GB3gYx6BdpgyapKZquLS
         Zx2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=bW8ImPyWYkqRlGFXBHr5QyjY43Bs1+Zz3QCbHLGpdic=;
        b=LcQ/dVfU3rRNAKqk3oSidW2DdqfQ+R1Z31t61oMie12DgfEgt1P2g0LKbMbEfKwkdQ
         9hUmFLsqSqfc0CTVsr7sCLrxzhlQArT+txkjpjdbCsAdQEBtImdCyxTtMJMIIpm1BWI/
         OTa+vVvABAR1sIA5t6AfFMSvHn7QTHcXZy751OXL9M5Atu284fFX5xcOoxOT7ELeNOEO
         zvfMmrWxYQ7zWuv+XdVgNY2GT8UDUsCUR+9dvzZSpQYuWRIFWC+2S6xsSQ9nt/1EBlcb
         Ky6THVaZg68vu50xfIUwJnwnr5ccQGd8DLb+cCDY2x2uXFKwy6ktTFRTfgrLNZVHujnh
         wnhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q10si5478689plr.347.2019.03.05.13.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 13:16:45 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 5AB6CF89B;
	Tue,  5 Mar 2019 21:16:44 +0000 (UTC)
Date: Tue, 5 Mar 2019 13:16:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oscar Salvador
 <osalvador@suse.de>, David Rientjes <rientjes@google.com>, Jing Xiangfeng
 <jingxiangfeng@huawei.com>, "mhocko@kernel.org" <mhocko@kernel.org>,
 "hughd@google.com" <hughd@google.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>,
 "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
 linux-kernel@vger.kernel.org, Alexandre Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
Message-Id: <20190305131643.94aa32165fecdb53a1109028@linux-foundation.org>
In-Reply-To: <8f3aede3-c07e-ac15-1577-7667e5b70d2f@oracle.com>
References: <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
	<alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
	<8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
	<13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
	<alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
	<5C74A2DA.1030304@huawei.com>
	<alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
	<e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
	<20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
	<086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
	<20190305000402.GA4698@hori.linux.bs1.fc.nec.co.jp>
	<8f3aede3-c07e-ac15-1577-7667e5b70d2f@oracle.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Mar 2019 20:15:40 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Andrew, this is on top of Alexandre Ghiti's "hugetlb: allow to free gigantic
> pages regardless of the configuration" patch.  Both patches modify
> __nr_hugepages_store_common().  Alex's patch is going to change slightly
> in this area.

OK, thanks, I missed that.  Are the changes significant?

