Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B4D5C07542
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 18:28:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C419D216E3
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 18:28:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="c268qRQW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C419D216E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FDB66B0003; Sat, 25 May 2019 14:28:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ADD36B0005; Sat, 25 May 2019 14:28:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 275B36B0007; Sat, 25 May 2019 14:28:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6C816B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 14:28:53 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p9so5810898plq.1
        for <linux-mm@kvack.org>; Sat, 25 May 2019 11:28:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w+IdEmKygnVp1QBgdc+S50lSqkJXJd/uGfLdmX1z2mI=;
        b=iJY+OFia34QdOAOhKVXrLHFHaaguUpm6D/aI3O2tHCSCCZ6lTcQMXrTQvQAXr4U87m
         SIPKh1flMpKZQvNKK0XGmL7GohEAzmPgouk8T+mpaYw9XygHYU6NpWX+kmaXHtUTQ2Tp
         DT2m/vynijODIQLXgbPpiW8/MKPsMu7LnEmSbBNZyY6f9OtX8XMvwnWdUhgtTJqWKMzD
         NDppK5LJ51SxRRPTSRlbveqCciTbnMo7UbOYvF4Pd89zMGEuVVOkmPBS3zwV7SwOo0E/
         sSkN/uu8xKh+2FTwtw+auxGv7yxbJkh1NMX2TcCxmIwFu5CL/IfB56J1u6byXmIbiDvb
         eKuA==
X-Gm-Message-State: APjAAAV2EAWvlGa7OwIp/BAg4f7imNd1unAid83xcqw0mJ6y21pni31a
	ZTgtXL00rIrA2uU6/rogGbJQfXOjzzGgHTFOJkP+60C6tzHw+/gDOWbPbE0+SciDnok9l1Oik26
	ddwRQrMgdOTCeOjhmFSOMoQLTXFqcJ4VgXI44a3+kFnoUGR3ppPRdbZHFJ/5g+jwAwg==
X-Received: by 2002:a63:4346:: with SMTP id q67mr113289144pga.241.1558808933502;
        Sat, 25 May 2019 11:28:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywgHztzogjlCX6THPdhUJpoXar3qTOsdnYsfEfJFZz1P7IJTI1ngn60e8vowiaSpvSLE6E
X-Received: by 2002:a63:4346:: with SMTP id q67mr113289088pga.241.1558808932741;
        Sat, 25 May 2019 11:28:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558808932; cv=none;
        d=google.com; s=arc-20160816;
        b=srDwLzJyA1PJgZDNr6nWbm3blqunUG9/huTieS5GyUowTcM7XuqEDeo6+DtXn1TZL1
         XMGhSyT663RasmBae8SuPsRn4x+yWERQT/X2Px/xcuAnjXL22GFkheWb2KdQ/I8jaSO9
         KkhvIvGWGatkSnC0VGAfR8No6dMxXFzJdbGcPYAKL8u3u6YhZokCz0k0XmR5oeBji33N
         zOfT2uSyNqm6qio1+x3sRkTfAlJZvTbS58BLd4Lt/tvwdE9FeCfUk7aOCUafUTnqol1y
         /MygYwOrIzAu1ORLW1KrTzJDJeIXcU2Fc2Tus1SVlHD7yW1FPZMR72t2jN1NVn6jjo2x
         iJ+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=w+IdEmKygnVp1QBgdc+S50lSqkJXJd/uGfLdmX1z2mI=;
        b=kU5sJx/j6BgCW5NMdKttLQuQvMOS9cV3XLVpcPaG1zNZt9faU0eQph5Rq58WOPOJ3t
         tfg/yISKSZg8YyKWtU19Ny5X+Tq2WqoT++nuWCK6Tn8eZpXNJgKRqvasNq/SnwGwMEjk
         A55RgAt848jw41fKaRnsKQeJMF37zNKWG0fEdJTrM7xBDbdKRw8cjxeKWCiija6/lUbt
         ldX7k5Vet3JjsXE4geKLUvIJtPzWK++vGcM3H4ECh8fOvJ7grOZvFHv+ykeXpNhq9kEy
         LE79GDus+Tb768tx7QLG3u+bPGxZd7axANYF1UUzDdzYE4svLpWzssLMIJO8kZZYoH4U
         6YIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=c268qRQW;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i11si10155225plb.416.2019.05.25.11.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 11:28:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=c268qRQW;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EDAB320863;
	Sat, 25 May 2019 18:28:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558808932;
	bh=o915ziI83Wq3DsJM16MhIJ37dE0MX7hNkXvLF1mxSSs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=c268qRQWAtxOlxLXaieeHQKVwLydKfkQ1kaOAyUmD8rZ5kPgeuW35L3VundqMz2ws
	 TKpWRCTzZ8coWST9lgDMHXMzGATDQxarTquKm4ZuZQkbKIhDrGjeXU+rXigaTuPjPT
	 LPC2G49gKq0gH2eeygnFjTHww2cX8TsGOwqjPKMc=
Date: Sat, 25 May 2019 11:28:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: <osalvador@suse.de>, <khandual@linux.vnet.ibm.com>, <mhocko@suse.com>,
 <mgorman@techsingularity.net>, <aarcange@redhat.com>,
 <rcampbell@nvidia.com>, <linux-mm@kvack.org>,
 <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] mm/mempolicy: Fix an incorrect rebind node in
 mpol_rebind_nodemask
Message-Id: <20190525112851.ee196bcbbc33bf9e0d869236@linux-foundation.org>
In-Reply-To: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com>
References: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(Cc Vlastimil)

On Sat, 25 May 2019 15:07:23 +0800 zhong jiang <zhongjiang@huawei.com> wrote:

> We bind an different node to different vma, Unluckily,
> it will bind different vma to same node by checking the /proc/pid/numa_maps.   
> Commit 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets")
> has introduced the issue.  when we change memory policy by seting cpuset.mems,
> A process will rebind the specified policy more than one times. 
> if the cpuset_mems_allowed is not equal to user specified nodes. hence the issue will trigger.
> Maybe result in the out of memory which allocating memory from same node.
> 
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -345,7 +345,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
>  	else {
>  		nodes_remap(tmp, pol->v.nodes,pol->w.cpuset_mems_allowed,
>  								*nodes);
> -		pol->w.cpuset_mems_allowed = tmp;
> +		pol->w.cpuset_mems_allowed = *nodes;
>  	}
>  
>  	if (nodes_empty(tmp))

hm, I'm not surprised the code broke.  What the heck is going on in
there?  It used to have a perfunctory comment, but Vlastimil deleted
it.

Could someone please propose a comment for the above code block
explaining why we're doing what we do?

