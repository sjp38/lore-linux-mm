Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07444C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:19:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF5EB217F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:19:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF5EB217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 652EA6B0005; Tue, 19 Mar 2019 18:19:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 628176B0006; Tue, 19 Mar 2019 18:19:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F1DE6B0007; Tue, 19 Mar 2019 18:19:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 137646B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:19:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so374406pfa.0
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:19:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=g+jA7D3Vy7vmz9uLJ0/t0Q5MAehw4oUvD4UXxiV4BFU=;
        b=ZiTS0p+s50gIkYXhM5aTMuStKI1xHjVo7YKk1dY1YgbLDMx2K1GHc7aXEH8UB19jK0
         GJXDnAT9CdmLEwi3KnN9ZSEf3eRbErIhT+kqgYb1OGZj5g+jzJHPVmK16ZjKY1rCJW51
         mRMh0EMTt3oCiWsaciKbj5I76gIXiLeWL3F8+Anbiad43XXJP/BlLSz6C3b4Cw0KGFtf
         VFY+h9Pcpq1JXMpwjzCnh2UwA15ZO95T10jvYhn7dPrzH7CzGs3CRhjgwvS3ivravWy3
         iyOPjQhh5bkWv+UDfuxJjmSCSy7HM4+GhkgoxC2BVDguwXkybHhyKRCntxF26QZpMMc2
         3vag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVeOxZB5/pf/EuCScqye4ZdAkF/XLVCAqCwkb+Prk7x61X23Aj6
	2B9okuM1dSAnE4d3To+CTzGCE9BeYu954LRVnTbwwcvcsDS4BqkrMFISgi7/9BFURiZZ7bjTV9A
	Z1gaVOR4/dg3tdkOwu9drvTx6WZGF9gCioJX33Bgz/zbvatYIpfbtARKa9fLpf2o53Q==
X-Received: by 2002:a17:902:282b:: with SMTP id e40mr4379542plb.111.1553033973719;
        Tue, 19 Mar 2019 15:19:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsw9LtDwyIcKME+uNjWyAQYDBH1uTfjewFeBssmWn6F889bZLzERs1R2Ofn5DQ4NHRsmMl
X-Received: by 2002:a17:902:282b:: with SMTP id e40mr4379494plb.111.1553033972800;
        Tue, 19 Mar 2019 15:19:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553033972; cv=none;
        d=google.com; s=arc-20160816;
        b=L5daX9386A0JWjX7+JUFLbjyhZf5rk9Ahc6r6rgTB2F1UcwljzZB/8VKhOdokx1VFy
         t1H98+3qSA5NIk+WYg1xRtHiI2zyaeiTlHDD0F5zb2o3Ucnn1GRcZkYEhxKkKfzcZYhT
         rWX8aw3blg4n4a6Puwuu1vara8OskdxF4ZdBGrsbFzvSUXxyobiJ5WKObFQyGestHNbm
         El1k5ni2694OIMHcDo2hYCedXJBXMJJ9KF++Qs/r957YZChCXyVubhR7y3RXYE5xGwBt
         N26g+iXWb7EaFNixstvKPiMH8B4xhKuYHUO8GMdnJGEAq73XG2AMsumXAngawvJdu3Zf
         NIhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=g+jA7D3Vy7vmz9uLJ0/t0Q5MAehw4oUvD4UXxiV4BFU=;
        b=rl4DUtuScFOUI2x4SY5VAW96WhpdctGj+YAvrltOcvkr1yA4LxigMwHyjHD99z5qIC
         X0wx2eV++o9hhFjPomnhX6/HmKDnOpx0k27swg0nZ/2f4C8m9xnHM05PLpqiaj+mu8U/
         Q0yMwbMzutSiUGdTMSKAA7z9l8T7/CBzpK0j+WiCqmAdI5vtYlwW7zPIoMHqX1bzkcsK
         ItV4kl/eGdtUKvBe2s6DrFp7wJVcgnvCO9Jx4h76cXaDXxfRjpf3EA2DnD7HpIE+9nbd
         FkAkr8epUw6QRONab57mbB7DohyA43at8XV5jw1FRrQNpSYzokukpicTE9A4UJsgHrsp
         vk5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y10si190703pll.142.2019.03.19.15.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 15:19:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id C3ACB3DA8;
	Tue, 19 Mar 2019 22:19:31 +0000 (UTC)
Date: Tue, 19 Mar 2019 15:19:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: ira.weiny@intel.com
Cc: John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra
 <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras
 <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle
 <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-rdma@vger.kernel.org, netdev@vger.kernel.org, Dan Williams
 <dan.j.williams@intel.com>
Subject: Re: [RESEND PATCH 0/7] Add FOLL_LONGTERM to GUP fast and use it
Message-Id: <20190319151930.bab575d62fb1a33094160fe3@linux-foundation.org>
In-Reply-To: <20190317183438.2057-1-ira.weiny@intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 17 Mar 2019 11:34:31 -0700 ira.weiny@intel.com wrote:

> Resending after rebasing to the latest mm tree.
> 
> HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
> advantages.  These pages can be held for a significant time.  But
> get_user_pages_fast() does not protect against mapping FS DAX pages.
> 
> Introduce FOLL_LONGTERM and use this flag in get_user_pages_fast() which
> retains the performance while also adding the FS DAX checks.  XDP has also
> shown interest in using this functionality.[1]
> 
> In addition we change get_user_pages() to use the new FOLL_LONGTERM flag and
> remove the specialized get_user_pages_longterm call.

It would be helpful to include your response to Christoph's question
(http://lkml.kernel.org/r/20190220180255.GA12020@iweiny-DESK2.sc.intel.com)
in the changelog.  Because if one person was wondering about this,
others will likely do so.

We have no record of acks or reviewed-by's.  At least one was missed
(http://lkml.kernel.org/r/CAOg9mSTTcD-9bCSDfC0WRYqfVrNB4TwOzL0c4+6QXi-N_Y43Vw@mail.gmail.com),
but that is very very partial.

This patchset is fairly DAX-centered, but Dan wasn't cc'ed!

So ho hum.  I'll scoop them up and shall make the above changes to the
[1/n] changelog, but we still have some work to do.

