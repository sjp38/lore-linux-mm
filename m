Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 048FFC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:40:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B56DD21B1C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:40:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fVw7r3Mq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B56DD21B1C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B5378E012C; Mon, 11 Feb 2019 13:40:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 664D88E0126; Mon, 11 Feb 2019 13:40:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57B018E012C; Mon, 11 Feb 2019 13:40:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4EB8E0126
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:40:47 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id n7so2522035pfa.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:40:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ai5ng9siExeClUBgwfnBsfOAh7Ww0UnChKfm7GQwqy8=;
        b=ovf9w+v/w3LF4EBI7sjBYkH/vHdlyA7LMWi7a8nEW/7It2Fx4yLAcbQoyxL9THk4VO
         EyLdHiQ1KLMh7+ivuvk0mQDcDMhl7gSf3Hvp7H3EWkWcMwU8SwgVFPllIie8bX30Lt2A
         S9LfBWGHsDH94ayJdQKN6Ywxcomw7IV7yxVv41ADQxk3yb5AzVPnF/c8YdqK0wc7ENQi
         XBMhd0jgnzeULrhQC30mUcT9HX9TYJDo+KOul0Hen4J+BlHOk3XuGBwSXCqd+Px/yhv8
         eI2zF/5lBSltGGSLlwx3pSbmSe/O++Uf12RXBa3/OPf9XFB3WbYETMI5VngC47+t98Pw
         nIfA==
X-Gm-Message-State: AHQUAuZf5DtQm2fadhU/MAWXF2u08LRwYpgWKGcjOsEF+LeQB9sB8AFi
	F1yRqdW1RFPWUd2nIK6ktOkWdU6mMPpOu3vG1dJkQhOven58ijOJRIz5kemRzjSB9JS6CeztMPv
	dWH5BBHHWS4yp8aAfjoa/X9xoff56MkB1rCIY+Vt1fVnc1GJCUQKIrqBFfh2mgcqOIA==
X-Received: by 2002:a17:902:b203:: with SMTP id t3mr10327133plr.243.1549910446788;
        Mon, 11 Feb 2019 10:40:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia02grMeWFeQr7pSFgfVE8WpEmhlWH2L61/U9J+wQCzpHHqhJmckg+LCqhbFV4iU04hxPd+
X-Received: by 2002:a17:902:b203:: with SMTP id t3mr10327061plr.243.1549910446077;
        Mon, 11 Feb 2019 10:40:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549910446; cv=none;
        d=google.com; s=arc-20160816;
        b=kOdJ7iaFEmJyscwydghf3dLfL3VbpFGPPhHwfze7v9UX6gkhv7CyaOULja5E8iO+8G
         wnsU20p/ClGtvurmIkli0m9x0IUOJYSj1bylwehpHN14gDZoISMqdrml6zzxL2ZiJAdf
         yGbBMkDEOyIO7Eo2CvxUonhVDQoybcD/Ae4McFI8N0xb/P89snwvHbtyFEN9UlZwSyPw
         xR2lyQGFfe6UMRLwwkgb587EjJOp5zTd/ABmmhtdQ7LekKXddoHcIeWJ0vmHMXhyc0Er
         kfAgB/nDmSOZpl9SPvMJEXlphtwCOPs1K3rWOyUlFRPDO34fbS3+B0eW8Wg9Up2lUC7J
         LcEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ai5ng9siExeClUBgwfnBsfOAh7Ww0UnChKfm7GQwqy8=;
        b=AibJC34oC12vQ7v2+MC4ibXE877fd/oAs/qWOVdWT/8Swy3e9ZJIZ8Xo3VTMK8vn5W
         0YFI93KMGECh3IaK8+DZ+77TY6jPZrDp1doXqYcMtS0OkLffu6Y51niLevYedfnY61Uk
         5V+XF+l2+5l8yXcINK18YSYi+5F+rUb/Z9ocUKY4fDvw/YpMD2U3Vl7ClrMikY+hTx6E
         RfzEAZMwLnvOgeMHujlo8vNrJLCshVb/EzVvLiig0F6SLIBnKMW3Pi5hGE3NVXRhOjEe
         iq7u+WNgs8PyanZzg8T37FpoL3UUXQaDPLToJNMsck6P0bCJczr1rNpRWBNNKjEL+XTy
         PK9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fVw7r3Mq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p65si626386pfp.140.2019.02.11.10.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 10:40:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fVw7r3Mq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ai5ng9siExeClUBgwfnBsfOAh7Ww0UnChKfm7GQwqy8=; b=fVw7r3MqWnUJtTl6mhVkXjfp6
	vM9c0a6AHbh6U4flVQBofzZmFJ7tWik+X7J/bOVW6acd8XxcqJUdUOFxACuHBcP2Xb03joVjDwJup
	yKI/y1HOhLWLkZeMt2EWaoAmg8w6l4Iy3pJpNi6iMlLw1JzPbw2sRi1bZh9vXkw/IH/CFJw+C+Dnh
	X5n1D5T13dh60kkz0g07H3phR8qFcQ8S5TEHS69AJPdUdJ3D1LeyRrw3GwIo+vNXFDGwWYPW4Nmdo
	jYQNctPjbwqrwZpGiOxpmaSQ30wm/1PC8CYlFMU0Sq6ilUE+vxNcAKdN7rd+uKFhyF7Wfe6iibTJd
	rhjUqcf9g==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtGVU-0004zX-H5; Mon, 11 Feb 2019 18:40:40 +0000
Date: Mon, 11 Feb 2019 10:40:40 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211184040.GF12668@bombadil.infradead.org>
References: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211182649.GD24692@ziepe.ca>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:26:49AM -0700, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> > What if user space then writes to the end of the file with a regular write?
> > Does that write end up at the point they truncated to or off the end of the
> > mmaped area (old length)?
> 
> IIRC it depends how the user does the write..
> 
> pwrite() with a given offset will write to that offset, re-extending
> the file if needed
> 
> A file opened with O_APPEND and a write done with write() should
> append to the new end
> 
> A normal file with a normal write should write to the FD's current
> seek pointer.
> 
> I'm not sure what happens if you write via mmap/msync.
> 
> RDMA is similar to pwrite() and mmap.

A pertinent point that you didn't mention is that ftruncate() does not change
the file offset.  So there's no user-visible change in behaviour.

