Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCC21C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:25:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7701B2084B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:25:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vMJvFxPK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7701B2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 161CE8E0003; Thu, 27 Jun 2019 19:25:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 113968E0002; Thu, 27 Jun 2019 19:25:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02B248E0003; Thu, 27 Jun 2019 19:25:13 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF5678E0002
	for <Linux-mm@kvack.org>; Thu, 27 Jun 2019 19:25:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so2531006pfb.7
        for <Linux-mm@kvack.org>; Thu, 27 Jun 2019 16:25:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S5r945Ps8zIT95EB0FGjitrKLPtkZ3f+rb5gk24+B1U=;
        b=VpQj/nzz2Zp2Cc+DUTO3ed6CwRrcbvmXxPxluJgdTnOqsudqzQjTcXhV154ikA54xF
         wesnGtat5Y6tvoa6B8Gv6XMBz8NtvZylFQAi5ZP8aDl2Mx+2NIoYNXKpcjmTitsxIh8j
         n1qdWM9cyVNK5PZI4Wx73uu5awqPs6BecB72FqjgxI0Xnad7gNMp/PksSXMgUTSOFBa2
         LzptrhgvNOn+R3YbHmlga+9YjkSnGEsGnHmN9/8FFxfK6rGSfwtW2luvs6TS5rVL6pCa
         BAVvSSEXd5dioZHd61wOeGYse4Sc0Ur/3ZCahMyUE51g8GLP4IBqIrwiMXZDO4S7Chd6
         z1/w==
X-Gm-Message-State: APjAAAVg0XhSfYwh8xzPd7wCQo92xxuzUdnB3MIpBRW9u2IBbjo9BaMj
	3zY1V2AkWdzQUOL9SGdLSD/GGoCavLZZ2THuZkjMs79+oavkIpoSdk0CIbFKYTckLTZc2bTM+Ax
	/d8zgMM2SFIPEcbEGxLCuiOimsYOcbuwcYTaa83NHoDn4Vtvl/y1K7o57OwxtlPFfkw==
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr9256890pjb.92.1561677913458;
        Thu, 27 Jun 2019 16:25:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZbyTJGXjRlKdrni07q2JzZ/eabeTgcZYtbvaxUx/tlZVYuhLsgYgdIDwSeV3/Obr8VsvM
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr9256855pjb.92.1561677912809;
        Thu, 27 Jun 2019 16:25:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561677912; cv=none;
        d=google.com; s=arc-20160816;
        b=W/2y9qxBO/+oBh5WfLgkmd4pAyqaObKl25Wl0mvUc/v0N8T0H8PNYgWtEvfr+vpWoa
         3DxVr1UYwiUBSy689gQO4t7Idy2m0NBjUF7/dKYXTKbZglREhXjEBEpXXNG7OAxx2wVr
         2RmU9/jStQ4piiG2ELcb9JVWWhM8hrpZZ4mhzqPIiPNhFsr7VQhYLIJFn82V2N71t1UB
         X6QT0t8lVvpAVowCR1B4j0n0nP2xyG6ghQcxT4pgfB0zYzZROSXBZepDG7K6TGm9kTr5
         q0/RfzODdqdCetjz6JNh6PAaNuNo4NB5R+3tijuvAck5HBWWGGBogpvMnJw9Fu4J7MsE
         p99Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=S5r945Ps8zIT95EB0FGjitrKLPtkZ3f+rb5gk24+B1U=;
        b=pxZGg2Kxpas76Jaqb+Bs5KLPPY8vwFvdbnPNYZYxTj/H0ewEZnxf/zx5kuQIvY74Y4
         IzXY0fmr9vWPyxC/pH2WKgzrcAROentCEmHF3Sux0mxIe69AHFpIITJUBkjBZxNllNIm
         f+dQcaStUP2hZ+IaEE6TODj5jvTT9MneauCQEc4oh+Qfm1FHnVyeTZugIbN7008d4L92
         AF+ehelC+pDsBQYtQ53BMEMIMQgrl+tLVqOw83RqGH6WdKwo+8ux1k/F5ovBoFK+Ldkk
         ZVPBvZPoCUmu5zCwwd1WR6ww5l4fvOCTPJl+uDAL+h9MMc46dpStu01saAeQx3IK1ThV
         Z+wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vMJvFxPK;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y6si446283pgp.222.2019.06.27.16.25.12
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 16:25:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vMJvFxPK;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 03F5120B7C;
	Thu, 27 Jun 2019 23:25:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561677912;
	bh=kNW9UJec5ndIC20H3O0Fi4cKff5mPU8oiMT2u9UKNAc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=vMJvFxPKezf+akCGBbS2o82bRQ7sHszgHAXZOe3/FHVG9GsJ/sIbmXcG2uVbE1HLh
	 CNlsy5NMinvlRYEnkynhONCRaUAGWckCTwiZYlA5C2v43HxFd6ruuGrLMZ1f4QOR47
	 oGngagpjO/hSp5S+6GDLPxYyDwe5gdN2ByAsgjso=
Date: Thu, 27 Jun 2019 16:25:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, Mike Rapoport
 <rppt@linux.ibm.com>, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>,
 John Hubbard <jhubbard@nvidia.com>, "Aneesh Kumar K.V"
 <aneesh.kumar@linux.ibm.com>, Christoph Hellwig <hch@lst.de>, Keith Busch
 <keith.busch@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>,
 Linux-kernel@vger.kernel.org
Subject: Re: [PATCHv5] mm/gup: speed up check_and_migrate_cma_pages() on
 huge page
Message-Id: <20190627162511.1cf10f5b04538c955c329408@linux-foundation.org>
In-Reply-To: <1561612545-28997-1-git-send-email-kernelfans@gmail.com>
References: <1561612545-28997-1-git-send-email-kernelfans@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jun 2019 13:15:45 +0800 Pingfan Liu <kernelfans@gmail.com> wrote:

> Both hugetlb and thp locate on the same migration type of pageblock, since
> they are allocated from a free_list[]. Based on this fact, it is enough to
> check on a single subpage to decide the migration type of the whole huge
> page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> similar on other archs.
> 
> Furthermore, when executing isolate_huge_page(), it avoid taking global
> hugetlb_lock many times, and meanless remove/add to the local link list
> cma_page_list.
>

Thanks, looks good to me.  Have any timing measurements been taken?
 
> ...
>
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1336,25 +1336,30 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  					struct vm_area_struct **vmas,
>  					unsigned int gup_flags)
>  {
> -	long i;
> +	long i, step;

I'll make these variables unsigned long - to match nr_pages and because
we have no need for them to be negative.

> ...

