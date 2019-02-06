Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7376C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:24:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AAA120818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:24:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="fDhEtHJ7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AAA120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E5B68E00F9; Wed,  6 Feb 2019 15:24:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 296758E00F3; Wed,  6 Feb 2019 15:24:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AE4D8E00F9; Wed,  6 Feb 2019 15:24:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5E088E00F3
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:24:18 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b187so7572344qkf.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:24:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=RyJanDr7XhsVpbX9gf4xaTMuyifJidFjn57I15YnXg0=;
        b=C8xMet9Y5T4dHfBV7S3yEomILQEWjW3BlTZT5TXj9ER5RJuW11/OS/iXhwp6vi1l1N
         nQ2E+srE6a0djW0F2KdPu3TCGGdYbEyajwFz8ePkUEtJ1GDmdCd6J3QiZ1C1xmIabExA
         m/kB1mxrOh9xI7soxLPgKsuv8eV9uxaNDkMb0UYOX/0AjKqtnaqpO3cNUJE0Dpv//2Zs
         HE7DoboVAzJ2C73ntV3clO9OwGknYlIBrMXuEACNyx2Oata5tUb54Jan9WaIIKgLADJj
         NZDbe2kLQZENcr0fguSgKH5fd66eiLj5drWTnLjtpn68a44a6JxalTSywb4ytFk9C/JJ
         mk8Q==
X-Gm-Message-State: AHQUAuaJ7Yy2Gyu7Jf05oGSz5tmdpwUwYEzlMehgixEB8+P9zcNh4AAg
	hkR53qLFvFcVBi+WWDMqccueGUqAZ6wMlqmKjOlVUWqcodYfwVsIpMVjFvDj6keUzVowzPNzlXu
	y1Yj9Y4Zg8KcANYtWwXgQ83jT3h4fE/WxCyZLTaXB4y7aJAoatXa0eegtcf5bhWE=
X-Received: by 2002:a37:8c04:: with SMTP id o4mr8499579qkd.165.1549484658713;
        Wed, 06 Feb 2019 12:24:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZwgvqhlq0SuTTET0tWG1OHYEcD7l6f/rHlohNBiZCQyk8YEQJT1zof5YXZDuRSWMCG5zAE
X-Received: by 2002:a37:8c04:: with SMTP id o4mr8499537qkd.165.1549484657978;
        Wed, 06 Feb 2019 12:24:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549484657; cv=none;
        d=google.com; s=arc-20160816;
        b=UXwNGe3n/olLtVsn/G3d2MPmYwKfkF9YF9gXYR/qn9Rf+XjtTyGzUr+3Wgm/jOZvf9
         PtIp3fP81t2dss78vtSbIJKqgcLIKNCwXbZWzwbFer8KGp88PN09H3MWTX/KCiAABmRp
         UpzO5WUMqlvzAEtYH2wUz4Z/IqS62mKu9Hn2693sWBJt6HF7Zr8ChyZa4rNNejJly9wB
         /+JKar56wvzMxa+dXiGRMAZS9oOPM79jENVc+7v/Ml/w8VZPH85HqcWcBtfq0HtDluiU
         vwq2t5X7fVXzQLjD0RAcjAACIQEV5nYubVEiaVZ2YOrysTc2jGfr/BuFZ6nFiWvYAMj/
         W3iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=RyJanDr7XhsVpbX9gf4xaTMuyifJidFjn57I15YnXg0=;
        b=glL0C63dlwDnDzRZUCShXxDAVMOkceUD1z/f+yqujZUokklwfKRa1Fa+CxbV6WBPxn
         4dSSMS0naBtjEF4+kVHXXBOeubeFlRl2j/IdMUjTa8/HsNTcMFnNVwrXXIC7/ohi4DwA
         hEo0JHgX3mEDMtVdgbLhe5BvEAM4zbHFTVNCxrtwZbcMn1f5N0YxFavZdO7KE95qdpJE
         VzD4yf/sG9zkpGkpTa3x+gPjFO4je6yKshjghApamsbUoWuO/Ouc2qIBkUp3qYwovSOx
         Ulza6uKMGKmwo01vlQ/HnMk/YhqWbl1SY3ziXOfGd9jar19azCV5pRmpvdHjThC5F9Kk
         4GMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=fDhEtHJ7;
       spf=pass (google.com: domain of 01000168c47b8b6a-ba1b2cd5-0a53-4367-a296-aa0b0ba26359-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000168c47b8b6a-ba1b2cd5-0a53-4367-a296-aa0b0ba26359-000000@amazonses.com
Received: from a9-32.smtp-out.amazonses.com (a9-32.smtp-out.amazonses.com. [54.240.9.32])
        by mx.google.com with ESMTPS id b88si4528304qva.135.2019.02.06.12.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 12:24:17 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168c47b8b6a-ba1b2cd5-0a53-4367-a296-aa0b0ba26359-000000@amazonses.com designates 54.240.9.32 as permitted sender) client-ip=54.240.9.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=fDhEtHJ7;
       spf=pass (google.com: domain of 01000168c47b8b6a-ba1b2cd5-0a53-4367-a296-aa0b0ba26359-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000168c47b8b6a-ba1b2cd5-0a53-4367-a296-aa0b0ba26359-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549484657;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=IKQJI6P5KcnC2eHGyyi/rgikGuil/xT/2O0jHHw10a0=;
	b=fDhEtHJ779ZPKC8QBWbnCFtyLqOeIlaDQN/k8z1KTzhCp5BQk+dZKBet4B90Tzyc
	yeBtEEaYgRGcTEZ3DxRl/n5v9qjNl6N4jsH5rTebfAfQkj/+8ZwEgz90nynwe0zI2+E
	UhrOAlWNgtMfKAm66GB0jaGbrePsyVanR4Sv9zWA=
Date: Wed, 6 Feb 2019 20:24:17 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>, 
    lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190206194055.GP21860@bombadil.infradead.org>
Message-ID: <01000168c47b8b6a-ba1b2cd5-0a53-4367-a296-aa0b0ba26359-000000@email.amazonses.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com> <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com> <20190206194055.GP21860@bombadil.infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.06-54.240.9.32
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2019, Matthew Wilcox wrote:

> >
> > Coming in late here too but isnt the only DAX case that we are concerned
> > about where there was an mmap with the O_DAX option to do direct write
>
> There is no O_DAX option.  There's mount -o dax, but there's nothing that
> a program does to say "Use DAX".

Hmmm... I thought that a file handle must have a special open mode to
actually to a dax map. Looks like that is not the case.

> > though? If we only allow this use case then we may not have to worry about
> > long term GUP because DAX mapped files will stay in the physical location
> > regardless.
>
> ... except for truncate.  And now that I think about it, there was a
> desire to support hot-unplug which also needed revoke.

Well but that requires that the application unmaps the file.

> > Maybe we can solve the long term GUP problem through the requirement that
> > user space acquires some sort of means to pin the pages? In the DAX case
> > this is given by the filesystem and the hardware will basically take care
> > of writeback.
>
> It's not given by the filesystem.

DAX provides a mapping to physical persistent memory that
does not go away. Or its a block device.

>
> > In case of anonymous memory this can be guaranteed otherwise and is less
> > critical since these pages are not part of the pagecache and are not
> > subject to writeback.
>
> but are subject to being swapped out?

Well that is controlled by mlock and could also involve other means like
disabling swap.

