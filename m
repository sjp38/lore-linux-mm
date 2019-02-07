Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 684B7C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:55:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11A3D218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:55:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="O9v0AIQ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11A3D218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FF198E004C; Thu,  7 Feb 2019 11:55:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AE6C8E0002; Thu,  7 Feb 2019 11:55:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C4618E004C; Thu,  7 Feb 2019 11:55:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE7B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:55:39 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so467012qtr.7
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:55:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=pWuOLMJMd2P+LB/b9Jo96S2QvIOE6IuAuX3pjQ4/Tb0=;
        b=MCyK0xc3sUAQsZvVwWWkFk38hvfQKnSUmin3tZoG7pBJGMeentOIQzy+KYzYvB1u9w
         9w/A+XwQt/unGB0qv62llnlnQAvlHqUibYDOSVLPF2jFZhI8f8e4L9FNSQ8FFMLSVyj4
         ThwYb+Bqn4oYnBJnnwIfwVyQuVZRQWsbh0ungcwPHSBIMWj6dfBZReaepANfB5n32woI
         CqPdCxrZLLWsAkOeRoMmHAsaqW3zt1H5+8YVr5wSIDH9rs+UdrWi682Qnd13KCtDXoYT
         e5SaxtSOxG6wap7aHDePlVWq29PBl+g3H5qn3p1WjfALbZkdmtD1AMZJ8rll8L9Xhj9c
         u30A==
X-Gm-Message-State: AHQUAuaByTjdaEBMDItYqgZFHwbWQPtpMjCSzzAesLH31uzOo7nOXg4i
	2EbEZu71TGxsUx+M7bbSm9ZA5uNpxgQwvDlLqwQrALD1fjAC9pbGnjOEAHVRn/SbWg/RlMcUmCH
	AWXXzXemUzS36jtucUr6+JdDbUlbYre6Xn2Xihp59WEcXDlxDYIy/n2cEj9SPxa8=
X-Received: by 2002:a05:620a:109b:: with SMTP id g27mr12140326qkk.128.1549558538968;
        Thu, 07 Feb 2019 08:55:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IakSSfKAI0c+7Z0sIxSpGI64vrurxsCKGuIuAcbhEcBAayK0lHUq1GyChEebpvFPa10qAMp
X-Received: by 2002:a05:620a:109b:: with SMTP id g27mr12140287qkk.128.1549558538347;
        Thu, 07 Feb 2019 08:55:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549558538; cv=none;
        d=google.com; s=arc-20160816;
        b=y74+u3UwfTrYk8pJyjvj1BIoQjPhaMz+ab1aJMlNyyjZiyT7wN2Wqrp6L4SKJaJmyM
         Ppnn7GNps1YGlEl5Lz3GWw8XE4YeioW2BSaNgPvp7VdfELP2BLWCFeBApfIdjIgfYgZ0
         vuA3zKx54bLUW6k9burPXpV9eApb2bt+LbPdUTpFTj+4uhMSWhEzHcc8NvH23GXfc/Hx
         dcz92hPlqkv4Ngr5XICkTJuQhVa1clY75nRQsKhZaE/485Gc6ChUsDdqOqbPFooQ4Qo1
         AQ6HtJ1ZJpxD/KuDqzdyerI1vEQZKUpO+UMU41DDL5qrnTuR4ugknZiFdoW0mJmCv93m
         kyGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=pWuOLMJMd2P+LB/b9Jo96S2QvIOE6IuAuX3pjQ4/Tb0=;
        b=cfaMrV49XIkj16D9pq0uAmFmFxyLwO4wT8reZ0gYu0UnD+3mTaJgZqH2odImGm7DfA
         poUpgUfI/Hjmy9l/DO2Oq96EM9Xdn/tJSEGt51u5fxngvYQW/PyOz7MI/41zozEjLfEe
         dmmvNvEctM74VnAsh8VZRJEGfPYg5fehJEvRjgPcwAwKQBNC1P5T72pb9hVPUTG3VdoM
         phKLJLT5cxMmkd6hpYz75ywV7mrZw4mPvrgSsc9sqmvtWuTDSHW2hwi+hzQoYRYfwkF9
         SrM0RLi2WipKnE5WQM6O2iFQf1obaU3rlck1vv/p81F7Z3Fe5YjqQwdLoV4fDtg5c8TW
         rTDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=O9v0AIQ6;
       spf=pass (google.com: domain of 01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id b20si2321834qvd.185.2019.02.07.08.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Feb 2019 08:55:38 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=O9v0AIQ6;
       spf=pass (google.com: domain of 01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549558538;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=kTxXE70S20OVI1msr1Fuki8Y508efNovX08aCTnuo4Q=;
	b=O9v0AIQ6CIgIh23VoHXzL1RwD9Rigp93j1vESMl+1EUEU4wW1lR8Htb1VtTJnyCr
	EwILSG3k/nilE5hLcJN278L0gbkYG6rzQ5DXODrl+PasyFAUKhv+m/9hi/6gPzS/w5P
	dMVACULsdkGGxCU0Z++c9rvYHJzQGsPQQZBxqqNA=
Date: Thu, 7 Feb 2019 16:55:37 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Doug Ledford <dledford@redhat.com>
cc: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>, 
    lsf-pc@lists.linux-foundation.org, linux-rdma <linux-rdma@vger.kernel.org>, 
    Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
Message-ID: <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com> <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com> <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca> <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com> <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.07-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One approach that may be a clean way to solve this:

1. Long term GUP usage requires the virtual mapping to the pages be fixed
   for the duration of the GUP Map. There never has been a way to break
   the pinnning and thus this needs to be preserved.

2. Page Cache Long term pins are not allowed since regular filesystems
   depend on COW and other tricks which are incompatible with a long term
   pin.

3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
   provide the virtual mapping when the PIN is done and DO NO OPERATIONS
   on the longterm pinned range until the long term pin is removed.
   Hardware may do its job (like for persistent memory) but no data
   consistency on the NVDIMM medium is guaranteed until the long term pin
   is removed  and the filesystems regains control over the area.

4. Long term pin means that the mapped sections are an actively used part
   of the file (like a filesystem write) and it cannot be truncated for
   the duration of the pin. It can be thought of as if the truncate is
   immediate followed by a write extending the file again. The mapping
   by RDMA implies after all that remote writes can occur at anytime
   within the area pinned long term.

