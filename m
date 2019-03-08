Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98EC6C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:15:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49E3B2081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:15:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="PaTfFJ61"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49E3B2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCD018E0003; Thu,  7 Mar 2019 22:15:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D78E68E0002; Thu,  7 Mar 2019 22:15:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C19888E0003; Thu,  7 Mar 2019 22:15:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1C78E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 22:15:28 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y8so18677125pgk.2
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 19:15:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=FtB7YHOvjTXAc8oTZpYQd0JJbEPfa0oBJdIjz2jF9Mk=;
        b=T0bpHctEM4bA49Fvzk0KIGSpPapL2/Tnd8kqlgEVgsN2tCKnnJSuiHZ4+N/EB9F7X8
         5GiWBH1KLB13LbZiDU9CywWTcErCXrppBpeXgcQfjHBVbIkcPqcqUGFDe8yVlQAwxV6r
         6rBmvpV2NeXDgmi42ORFh1JsbCU46ekwCzcGKGfEpovfDcZoASWZobC5lsW6BCfsrK3w
         FCUFs1OtkMjBh/FSInxYWJhGTn3W1sWRYBnujLQvaVCAMWa2WXUreQPo19RrHRy31vSA
         V3zICtKwT20g18L7N/GBWu0YyTgBL2z7m/X754nkVkH72RNBJud5fAzUtBg2BbCDR8bc
         jR8g==
X-Gm-Message-State: APjAAAUeUXstviMl8JWH/32ZLjT36zxFtUov9IkpplBUu8cgpvyPMTzW
	vCYlZju84aaFlczH6q8HaXePhwpdwDVUnvnJb+mAOv6mP3FRW41FO3MVkGleQmUeIS4zXj4cpK2
	/ZFRX16m4qQUdOReno1cVgSjCFNgA1eE899/yZA03YXDYzLAo63N4Jsfkw0mbZDvXhQ==
X-Received: by 2002:a65:43c7:: with SMTP id n7mr1742661pgp.173.1552014928053;
        Thu, 07 Mar 2019 19:15:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqxB0hQDGtcuXeO9wAkyYzWTRJEDvj+jIavWE6vhyixHRGmSzPJF32sQ39KpMRD9lgvOAqoQ
X-Received: by 2002:a65:43c7:: with SMTP id n7mr1742582pgp.173.1552014927061;
        Thu, 07 Mar 2019 19:15:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552014927; cv=none;
        d=google.com; s=arc-20160816;
        b=zDO9s8OWjA0j2pDD8fSFLatYTT5R2FsZjlIH2RCvGTpd/qOfIqk2rhiQhdoC4+HGm8
         Wn03LswY9C7reJJ6/fWMTKJuByuaQOyn2i03p3V/xMnJydkHKmcnypj1TEGv65AVQjkU
         THK/vqxjrX8YR4IDDqejWUlEYaer15Nac12yD6brPWfp872vQcY9GTRbZju2Cn/4EA5O
         mxlNwdlOdaC0G/eBgvzQrtMKfbLg6lqIKqyjAm0cEadxUWY/CkEwixfh4J/uvxDE+ntK
         TO2UiYMxeDacnuBifHG88+kVbEYM8tGH2LwndvyLHEu4uhf/PQNA8m3ydLtQzATfFiDs
         Do1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=FtB7YHOvjTXAc8oTZpYQd0JJbEPfa0oBJdIjz2jF9Mk=;
        b=N0H34qXu0dLpa0ngJPvHLydpUB3j/NhI3EzQHNtowHIKYoAvEOWYK9cSgR/2mkErHL
         CChS5SoThtjaA/3xF/gwd6PAfeQzJiskr8K0+JyU5F4dTn4E7lO5i2Ix6z6wT119OxOn
         P5PTSWVWBKtlZ0slYPmAiLHH43lhkLCxG1gjCS+btIh3SNtP5rAreOh98NOikCzat1xa
         MTSZxt8iNncnRlIYkI2IQNYfZGEXXUaFubi+5f0cHOtS/YDvTAggRRBuEy7/7BgLv5uz
         oxft8wXGSuHoDNcpDB5uCPQc6iV7OXW12/f1xxkKqKJHdwfn9Nc7AdU2/6zBeh4Pxj8Q
         cD1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PaTfFJ61;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id a18si6001621pfc.23.2019.03.07.19.15.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 19:15:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PaTfFJ61;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c81de4c0000>; Thu, 07 Mar 2019 19:15:24 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 07 Mar 2019 19:15:25 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 07 Mar 2019 19:15:25 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 8 Mar
 2019 03:15:25 +0000
Subject: Re: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Christopher Lameter <cl@linux.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave
 Chinner <david@fromorbit.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <20190306235455.26348-2-jhubbard@nvidia.com>
 <010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@email.amazonses.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <3cc3c382-2505-3b6c-ec58-1f14ebcb77e8@nvidia.com>
Date: Thu, 7 Mar 2019 19:15:24 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@email.amazonses.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1552014925; bh=FtB7YHOvjTXAc8oTZpYQd0JJbEPfa0oBJdIjz2jF9Mk=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=PaTfFJ61biJBo7uGPG2BuzWxq8swoNQ/7IQR8UHih2Tu3sE0fdYuM9voZ54bMHgpE
	 A/wSahEtYBX4SyO9mpKc29e/BW9s/KI4sb7BR1shM0kuRVd6zTZBqc4vyS4jWzCyrD
	 WJKCcRWIPxCX7g1pQo/UJ/Lonhb8umOa8LdmJr2C8R5Q6v4lr3mY7XnRgyJzuY9OqB
	 vu4A+0gyx3UG3ekzq8Tjx+WmoXxfj5enhPv+34k6qj1B+QhTxVcQyOF09nU12kOaG3
	 yfRwyvP9AXMEakDrS+OYChxyAvM8F5M7CKeFFXU90VOHh3agHsllvho0m9E/azcvLL
	 MvIP9G1BWJuDg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/7/19 6:58 PM, Christopher Lameter wrote:
> On Wed, 6 Mar 2019, john.hubbard@gmail.com wrote:
> 
>> Dave Chinner's description of this is very clear:
>>
>>     "The fundamental issue is that ->page_mkwrite must be called on every
>>     write access to a clean file backed page, not just the first one.
>>     How long the GUP reference lasts is irrelevant, if the page is clean
>>     and you need to dirty it, you must call ->page_mkwrite before it is
>>     marked writeable and dirtied. Every. Time."
>>
>> This is just one symptom of the larger design problem: filesystems do not
>> actually support get_user_pages() being called on their pages, and letting
>> hardware write directly to those pages--even though that patter has been
>> going on since about 2005 or so.
> 
> Can we distinguish between real filesystems that actually write to a
> backing device and the special filesystems (like hugetlbfs, shm and
> friends) that are like anonymous memory and do not require
> ->page_mkwrite() in the same way as regular filesystems?

Yes. I'll change the wording in the commit message to say "real filesystems
that actually write to a backing device", instead of "filesystems". That
does help, thanks.

> 
> The use that I have seen in my section of the world has been restricted to
> RDMA and get_user_pages being limited to anonymous memory and those
> special filesystems. And if the RDMA memory is of such type then the use
> in the past and present is safe.

Agreed.

> 
> So a logical other approach would be to simply not allow the use of
> long term get_user_page() on real filesystem pages. I hope this patch
> supports that?

This patch neither prevents nor provides that. What this patch does is
provide a prerequisite to clear identification of pages that have had
get_user_pages() called on them.


> 
> It is customary after all that a file read or write operation involve one
> single file(!) and that what is written either comes from or goes to
> memory (anonymous or special memory filesystem).
> 
> If you have an mmapped memory segment with a regular device backed file
> then you already have one file associated with a memory segment and a
> filesystem that does take care of synchronizing the contents of the memory
> segment to a backing device.
> 
> If you now perform RDMA or device I/O on such a memory segment then you
> will have *two* different devices interacting with that memory segment. I
> think that ought not to happen and not be supported out of the box. It
> will be difficult to handle and the semantics will be hard for users to
> understand.
> 
> What could happen is that the filesystem could agree on request to allow
> third party I/O to go to such a memory segment. But that needs to be well
> defined and clearly and explicitly handled by some mechanism in user space
> that has well defined semantics for data integrity for the filesystem as
> well as the RDMA or device I/O.
> 

Those discussions are underway. Dave Chinner and others have been talking
about filesystem leases, for example. The key point here is that we'll still
need, in any of these approaches, to be able to identify the gup-pinned
pages. And there are lots (100+) of call sites to change. So I figure we'd
better get that started.

thanks,
-- 
John Hubbard
NVIDIA

