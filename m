Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F63C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:21:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EB762075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:21:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="aVKPXXb2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EB762075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A1A98E001C; Wed, 13 Mar 2019 15:21:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 429738E0001; Wed, 13 Mar 2019 15:21:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F18F8E001C; Wed, 13 Mar 2019 15:21:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 036068E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:21:39 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id i3so2942823qtc.7
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:21:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=+/NfNXWl+B8nDZmsoLsXblISt5zHA91zPSRD2oVDv74=;
        b=cSzaBOizzZAj932sYg9Hp0hx0B+W0b0KyIZIqT2lePluGlT61nYPQxqSqnS4wSv6+o
         2xHRkSrc6bSR5AkyzThK2PMoilAtrt6NS56DFjBf0z+dxoZOHVl/e0sb75uiVHLloteV
         +k8G2yxYfzLn5ARxVXHWkOv2ILBQpDi3Pr9BKuymlQuvKd7Uz9LZYdLydtKzbKSZRtZ3
         OHOZ3ktmFieCSSbMGhk+ljgVMPRbtll2NjnUoRGkhQ8t/wfWtIO9lxweqXeN+8tm3AjC
         Kn9kmUbbQ6QJgvNBWlirhKkdSoQR3hhoOCi9VmBv4WWsMlUMxSyAKRHaSON5WDGaMQKk
         Wvow==
X-Gm-Message-State: APjAAAUQsKMYy1OkJEIfNzAzAIhEldUbVkCA6/gQAGeIWePQkWW5ieZv
	rfCXUkt52S2MQB8la+B64D4jXw1SBRKwhZ7aQ5CleMqytJPQIxO5ShDcfTBrVBOgDvIFJeJUwXm
	BrWbsZ3dCqEUR2nXnxZMXAS3OeJuSfueTF3dlE0UVdP27+CDp85sYM6qCUgAk854=
X-Received: by 2002:a0c:c30e:: with SMTP id f14mr3505409qvi.195.1552504898824;
        Wed, 13 Mar 2019 12:21:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDcfnRSK+gpCChvgC1BNgRnqigs8aYpI2YCHwaGjmuS/TxGW2Aw8eNOCEL3S8H99cEv4l9
X-Received: by 2002:a0c:c30e:: with SMTP id f14mr3505378qvi.195.1552504898181;
        Wed, 13 Mar 2019 12:21:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504898; cv=none;
        d=google.com; s=arc-20160816;
        b=K075ybPOIPLmt3ZblTiFDa+R5/1z1wVF1pBk2yO1VBp/cEregnIckUNSWxUxj6DkO9
         z8Bo0lIbKxj8dX7e+FoPQEjR/qdY5LJDWup3QknXCGq1ObgN+BxIjf5ltm1bBrmSZNUs
         qnPpPrcBj2ZBlrhgkDMRXKSrH3BLvwbvVkx7r3OmObfj8DHwfGha5QTpW6mQqYQVYQcL
         flkTg+zhaauroTh8EvNoze9CW8Pm4jnWyESJTJwk2P8TvXJ5h4UAPDI4u7SMH0XFreIe
         CMlXEljOzve0pxiWzksrGx+XI4O7MpZfGXYVAmRAJBnHJYt2vYn1HoyweGiQq5vY9RI2
         P/Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=+/NfNXWl+B8nDZmsoLsXblISt5zHA91zPSRD2oVDv74=;
        b=G6YMs14aSyItFPkrUdrgyPGqg12rT6wv3h9I7lNaJvy23EE/9cbA2X6tNOvK426DbX
         jvFQ7zAJbSLNZbSHmPAJRITStEzClM2bbLZAojk+f0hR1a7EFtetP8C6vhP99zIwKoyX
         kIfkqBtms/Lc+ramN9QTBbkWeUR1Ar5oWQ0MMFXIQ2NfFxb6rlE7SpkvOfoRDPF1Hwi5
         YpNZXAkUhdIEyujDFTF4bUAItn/8HpK3GX6yfbfz6YzH4FBWpl16DOOj/s0kWO+exiKN
         j69dcvYLb0KuKdqtopYk+61GN05YKibgg7uXNdQvYayuZuAkT5uWaH6Ml7LfGkaIlDey
         GTig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=aVKPXXb2;
       spf=pass (google.com: domain of 010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id y14si2681615qvc.45.2019.03.13.12.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 12:21:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of 010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=aVKPXXb2;
       spf=pass (google.com: domain of 010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1552504897;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=SfWdjvUkwZe+2Dd4vugu5sfhOkXcR0c1mSWLWevFMhQ=;
	b=aVKPXXb2dmDsuNCuoE242Hhb6DL9Dz/3VVvfCRCmcoewVXQ6E4W2y6kaNFzmhegf
	51+NZvO/T47ln0z/M/zfOaOCUdoOyyj+3J/3laE7SgaayKBr3K6nkMnGUYrJyPUO6C/
	SnwSnQZll03tXHxBP9oj1tuhomYOFHWeP3Zt4SD8=
Date: Wed, 13 Mar 2019 19:21:37 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Christoph Hellwig <hch@infradead.org>
cc: Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>, 
    john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, 
    Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190313160319.GA15134@infradead.org>
Message-ID: <010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@email.amazonses.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com> <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com> <20190310224742.GK26298@dastard> <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
 <20190312103932.GD1119@iweiny-DESK2.sc.intel.com> <20190312221113.GF23020@dastard> <20190313160319.GA15134@infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.13-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Mar 2019, Christoph Hellwig wrote:

> On Wed, Mar 13, 2019 at 09:11:13AM +1100, Dave Chinner wrote:
> > On Tue, Mar 12, 2019 at 03:39:33AM -0700, Ira Weiny wrote:
> > > IMHO I don't think that the copy_file_range() is going to carry us through the
> > > next wave of user performance requirements.  RDMA, while the first, is not the
> > > only technology which is looking to have direct access to files.  XDP is
> > > another.[1]
> >
> > Sure, all I doing here was demonstrating that people have been
> > trying to get local direct access to file mappings to DMA directly
> > into them for a long time. Direct Io games like these are now
> > largely unnecessary because we now have much better APIs to do
> > zero-copy data transfer between files (which can do hardware offload
> > if it is available!).
>
> And that is just the file to file case.  There are tons of other
> users of get_user_pages, including various drivers that do large
> amounts of I/O like video capture.  For them it makes tons of sense
> to transfer directly to/from a mmap()ed file.

That is very similar to the RDMA case and DAX etc. We need to have a way
to tell a filesystem that this is going to happen and that things need to
be setup for this to work properly.

But if that has not been done then I think its proper to fail a long term
pin operation on page cache pages. Meaning the regular filesystems
maintain control of whats happening with their pages.

