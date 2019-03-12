Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CE1EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 05:23:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AD032087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 05:23:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="h93TzIKV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AD032087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1F2B8E0003; Tue, 12 Mar 2019 01:23:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A66D8E0002; Tue, 12 Mar 2019 01:23:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86EC98E0003; Tue, 12 Mar 2019 01:23:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF4B8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 01:23:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d8so1240883qkk.17
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:23:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=z01aYAg46TzuTIqJisqKm8re0ji3PJzla2eSuVgDaEg=;
        b=Y2kQtEd0jBCgPXFi+udK1lU9JiOHYA0LzrsdGZ6oVYc4Egu3f3mNTQ9TNaRVfJfEff
         wtSKj6blbAc4gBBH71mt+jTujtzYEP2Z8LfdaXZGX+hg0QY3R4lwwka/vEm78DhbzhK2
         Rzx8eXRuDG5pvCzbL4jNXTyMmGJNY5kDdifx72e1fN0IgkpWc/Is8GaVJdMaVOWdFK1R
         /SBrpTWIRLH0JFZ2iSOmn/JBuDlraHPjBXfY4ei/3bNTA0BM1AJPpiQUAYUWely2Mh9e
         Mefrl9hkrI7GnfVAS8O9Z5SCzdj/3a2jEcvGkYCGOopTpOsdWx795syTjCL2Lvki1vxD
         V60g==
X-Gm-Message-State: APjAAAUCEdN1mkpHVl7QLGT8Q3v1JACvXNOHqHHAFlxrJvpjX3jLP9nm
	DdXPV/t73cpjzuR2sfGKruTepoysAq0J5nIW0pt31FAXj3BifBPLLnhjfhOWYKe/ljIoGYGAjRv
	Q9AtSumAUlGk1o42red55eRqNk2hnR5hg0RzL2x6L7jXH46QqqKGYJCql9fbzYPo=
X-Received: by 2002:ac8:3258:: with SMTP id y24mr5236131qta.0.1552368202159;
        Mon, 11 Mar 2019 22:23:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/5vgQ2lnBWB8rigM7sLKUYtdAxp/oOLkzM+glao8I/umv3849X1BxLBGP/D4V9x49tD9O
X-Received: by 2002:ac8:3258:: with SMTP id y24mr5236112qta.0.1552368201525;
        Mon, 11 Mar 2019 22:23:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552368201; cv=none;
        d=google.com; s=arc-20160816;
        b=pVWhUUERx+v2JyjVBTXJQOIhPJbtmXos1IOe2pvfAgcslCn1I60XaDCEuHvWOFRZ53
         Lb0WNiC0PkIdQmFrWi6r0IdNeiGQvzru7RkBQAosVyr3FfC9OIwxr8+6t1z+MQemH2I7
         0rh7DZYqks8/NeXeT8poT7rxoqt5cuGrPZTrpXZ1A4RBjkre0iaKE151fr1sWcDpMWsm
         F+auB5druaq4yWeccxTmPQSL6pV9NcFYXleMovjrz0144nLHeadXgfCkpiJGT6zK5Zw+
         K6/IIUbFK0qNaDQ8MlN71kxVKlRDQlYty0cya7jr2FgQw0gf4ZS1cmg+4I+wBqBFZKqX
         nWhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=z01aYAg46TzuTIqJisqKm8re0ji3PJzla2eSuVgDaEg=;
        b=lVhSZj5Z1sVsFmwZtP+vbN+nsCPxoyqLtssBPGyRKQklDppMU17NamxnY7KMDE8MyS
         r0wLRr+FBBUGG5KumZMc3gqR6c83RoFvX7eqaqZDODnKBDGzYdQVYe7RAh6m6nxG4nYk
         HyxIN6Wr7i13z0hFdv9JQOJettCAQfXA/qwLY+2eJEHklKhm6Rfvmo3flrTWFNVyG+27
         cEasHx8DBHZJqiyFr2h+RHHqx89vDbr/qCAhdSnfiXgSJ4wzsE/DIatvRBipQc7EL/2N
         2aPgswsgqy2JUPPj7hOz7vFFkF5CFVB10c/jNMitG4HMzykztzuB140MC5Os/22svtlD
         tShw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=h93TzIKV;
       spf=pass (google.com: domain of 01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id y141si4595838qky.221.2019.03.11.22.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Mar 2019 22:23:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=h93TzIKV;
       spf=pass (google.com: domain of 01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1552368201;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=z01aYAg46TzuTIqJisqKm8re0ji3PJzla2eSuVgDaEg=;
	b=h93TzIKVo3t5INkiUh683/9f5Ugs9bfgUZdPiU/mr0UMqzn5NDgBRiJ3s5JEF+q8
	MCB0EzTQifuAOul+pMn3x3RE6Uc8yfiVVPn2ZlbQ2S6YRNPiiBPKCSP9WUi6vkuKjqx
	+lSakYv0fmIQcKCWRIscw1prKTsiJYtGzxtnpPis=
Date: Tue, 12 Mar 2019 05:23:21 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Dave Chinner <david@fromorbit.com>
cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190310224742.GK26298@dastard>
Message-ID: <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com> <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com> <20190310224742.GK26298@dastard>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.12-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Mar 2019, Dave Chinner wrote:

> > Direct IO on a mmapped file backed page doesnt make any sense.
>
> People have used it for many, many years as zero-copy data movement
> pattern. i.e. mmap the destination file, use direct IO to DMA direct
> into the destination file page cache pages, fdatasync() to force
> writeback of the destination file.

Well we could make that more safe through a special API that designates a
range of pages in a file in the same way as for RDMA. This is inherently
not reliable as we found out.

> Now we have copy_file_range() to optimise this sort of data
> movement, the need for games with mmap+direct IO largely goes away.
> However, we still can't just remove that functionality as it will
> break lots of random userspace stuff...

It is already broken and unreliable. Are there really "lots" of these
things around? Can we test this by adding a warning in the kernel and see
where it actually crops up?

