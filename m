Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF0666B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:43:23 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id l7so3467178qth.22
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 03:43:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u190si8290664qkd.288.2018.02.12.03.43.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 03:43:23 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1CBgXEH050674
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:43:22 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g35j3jvjp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:43:22 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 12 Feb 2018 11:43:19 -0000
Date: Mon, 12 Feb 2018 13:43:11 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-5-igor.stoppa@huawei.com>
 <20180211123743.GC13931@rapoport-lnx>
 <e7ea02b4-3d43-9543-3d14-61c27e155042@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7ea02b4-3d43-9543-3d14-61c27e155042@huawei.com>
Message-Id: <20180212114310.GD20737@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Mon, Feb 12, 2018 at 01:26:28PM +0200, Igor Stoppa wrote:
> On 11/02/18 14:37, Mike Rapoport wrote:
> > On Sun, Feb 11, 2018 at 05:19:18AM +0200, Igor Stoppa wrote:
> 
> >> + * Return: 0 if the object does not belong to pmalloc, 1 if it belongs to
> >> + * pmalloc, -1 if it partially overlaps pmalloc meory, but incorectly.
> > 
> > typo:                                            ^ memory
> 
> thanks :-(
> 
> [...]
> 
> >> +/**
> >> + * When the sysfs is ready to receive registrations, connect all the
> >> + * pools previously created. Also enable further pools to be connected
> >> + * right away.
> >> + */
> > 
> > This does not seem as kernel-doc comment. Please either remove the second *
> > from the opening comment mark or reformat the comment.
> 
> For this too, I thought I had caught them all, but I was wrong ...
> 
> I didn't find any mention of automated checking for comments.
> Is there such tool?

I don't know if there is a tool. I couldn't find anything in scripts, maybe
somebody have such tool out of tree.

For now, I've added mm-api.rst that includes all mm .c files and run 'make
htmldocs' which spits plenty of warnings and errors.

> --
> thanks, igor
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
