Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71202C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:50:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CB5A2147C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:50:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mYsBJPmT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CB5A2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF99F8E0002; Thu, 14 Feb 2019 15:50:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B57368E0001; Thu, 14 Feb 2019 15:50:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A20AA8E0002; Thu, 14 Feb 2019 15:50:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61EC18E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:50:54 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x14so5185494pln.5
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:50:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MeG5zKc2UE0WieoqB3MtbxjtjTruWyk7aA1ukjpUZG8=;
        b=fBQ+kWEbF3tevncUcf0881QpA+fYU62CkWbBoTCpYW6YpRbUrw8rb4IiGuLQumO1Vo
         LszYVnotCJPaRDSvdv9MMJysNfEgGKJNT+MFjxWMVPONn+lTdqPxp5gMul5pTRMSbozS
         T4yFUKs6TOyyP357d0bWPlY0UF3FAdYAk2CVgKmbPOuBhP7Zzi2RLvb/lc7T8/Me9ZFz
         NTUZ5oIbKMJmJkYm0MP1PNleftfsxON2pehvhj4D1Z60gzOGYnRG0QIIWzVRluxV7A06
         YSqLMsorZUiDQVJcCwrGy8BTQQkORiEmaJjzf0Kgs/6EoX0DWTc3XJScr/MQNL7lbNeu
         jniA==
X-Gm-Message-State: AHQUAuYbqMG84WmNPJ/VOzMmOQT6zUGQW/Mtyz/dN6dDYgb0uarQHDRl
	VDMtOh8vtx6l9R5lS1rXuD3s394Rx/u7sYzw6uCavi/hJXn+74AGL+P+ItiDl9RHw/2Vr4RFBMg
	PHxTG+tbLJuvvk01kuGkWDzcfxp9AmqNMe37gxeYLvd68EdV+rI17x2pb3MYBiy5Imw==
X-Received: by 2002:a17:902:ab8f:: with SMTP id f15mr6281769plr.218.1550177454074;
        Thu, 14 Feb 2019 12:50:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYN7va5EwAvqhxGU2jhgBSCFKFVmdkzy6VkT+/XAhMrJqjfN7saf3K/h5fXMzl9R+U/dfUY
X-Received: by 2002:a17:902:ab8f:: with SMTP id f15mr6281723plr.218.1550177453296;
        Thu, 14 Feb 2019 12:50:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550177453; cv=none;
        d=google.com; s=arc-20160816;
        b=AwNwr5qVlu4F4iWOiYSYa9L9tzFB+ym+4QHxWBYEsfGy+z7nviotaBEf1sok7aFNCI
         5sF4SI+B9H84+vhRhn/EA4kksfAfaby5a43s2Vl/W3ctgOHnaycVWh0pzuPqfiXUGD1A
         hLtdkatb9UKQXiY9uD00pyaO0ykgBytDy6a9ECPKsBX4ElAiHd0+080i5nPyO3FJ/Quu
         Bp1aT9+G1/w8N00dKDW2satWx943QLUFDLcFOTYOTExE8XCCddWmqdZDmy9HclW+yMGR
         DlyBKyAhJCYxpx4R69Z+fCsaJypLU1HqvnOxgCHxJ91bQ2ZlwwdJvvAakkiTkVlnp2m3
         rbGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MeG5zKc2UE0WieoqB3MtbxjtjTruWyk7aA1ukjpUZG8=;
        b=HErYo8oMRYTsJ5AXLCqlgdwqng5kt99ovHz9Xmq7HmDeWQD1AKEfhFDwGOqkI9phLp
         pGNHqJZ2MbnrmqeYD77WklXVLduLfQzkdaP3VUS56Z74c/NBGqm4ykaC9BLSCM0oLniF
         p1wETm3vGrETXWuUKkX2Dmq4L9mU2c7aca/3uOz/afrd3npmms1C05UJHfgs13t8v0Ul
         E6pqVbDCq71pHrZdU1sSTver8SQlYYZlQe6NWdfvTwCGUUZPaoroTJ0ZuhM3PFNofnwI
         nzqq5o5EV6/0tb+a25MRbj9QvQ6rH9WUHik8etjV7u/JKVC2qASMCghfHq1/aT/TImIb
         m5og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mYsBJPmT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d12si3282995pga.506.2019.02.14.12.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 12:50:53 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mYsBJPmT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MeG5zKc2UE0WieoqB3MtbxjtjTruWyk7aA1ukjpUZG8=; b=mYsBJPmTtZhQzy0ZO8CWKmZjk
	EeFJMVF6VsZNK4WQKcHFoEaGMjsISWtXhyHOzdW2h8ZWGqidCeQe6MdGafFyrmTAthg9Y6Z+BghdJ
	MUdM20P8ab3cw8KNk779YGfh4B9dmRQn0JQUoQ0JHntGaffI+ITQGPBYeEuW/Ja7MP/wmDzXPlXj2
	K56uXU7VU2y8R/UERH5Fi5p8bthi53qYRJ/3p9Wp8Y7O+LkUJTQLLjOt8Fre5fgiVg9OkMLO2vm5N
	NgVbd2lJauoEGzKymG0p5O85NEPWV3cDDOqKzXmDF31tklfVsOEWh8v4Q8un8hrhhHGhRBFOC7grr
	mIaRDnZrg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guNy5-0000Qd-MR; Thu, 14 Feb 2019 20:50:49 +0000
Date: Thu, 14 Feb 2019 12:50:49 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190214205049.GC12668@bombadil.infradead.org>
References: <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214202622.GB3420@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 03:26:22PM -0500, Jerome Glisse wrote:
> On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
> > But it also doesnt' trucate/create a hole. Another thread wrote to it
> > right away and the 'hole' was essentially instantly reallocated. This
> > is an inherent, pre-existing, race in the ftrucate/etc APIs.
> 
> So it is kind of a // point to this, but direct I/O do "truncate" pages
> or more exactly after a write direct I/O invalidate_inode_pages2_range()
> is call and it will try to unmap and remove from page cache all pages
> that have been written too.

Hang on.  Pages are tossed out of the page cache _before_ an O_DIRECT
write starts.  The only way what you're describing can happen is if
there's a race between an O_DIRECT writer and an mmap.  Which is either
an incredibly badly written application or someone trying an exploit.

