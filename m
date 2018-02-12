Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B20636B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:53:58 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 78so3446084qky.17
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 04:53:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q8si8418964qke.278.2018.02.12.04.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 04:53:57 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1CCqbnK040660
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:53:57 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2g392knasb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:53:56 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 12 Feb 2018 12:53:55 -0000
Date: Mon, 12 Feb 2018 14:53:47 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-5-igor.stoppa@huawei.com>
 <20180211123743.GC13931@rapoport-lnx>
 <e7ea02b4-3d43-9543-3d14-61c27e155042@huawei.com>
 <20180212114310.GD20737@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180212114310.GD20737@rapoport-lnx>
Message-Id: <20180212125347.GE20737@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Mon, Feb 12, 2018 at 01:43:11PM +0200, Mike Rapoport wrote:
> On Mon, Feb 12, 2018 at 01:26:28PM +0200, Igor Stoppa wrote:
> > On 11/02/18 14:37, Mike Rapoport wrote:
> > > On Sun, Feb 11, 2018 at 05:19:18AM +0200, Igor Stoppa wrote:
> > 
> > >> + * Return: 0 if the object does not belong to pmalloc, 1 if it belongs to
> > >> + * pmalloc, -1 if it partially overlaps pmalloc meory, but incorectly.
> > > 
> > > typo:                                            ^ memory
> > 
> > thanks :-(
> > 
> > [...]
> > 
> > >> +/**
> > >> + * When the sysfs is ready to receive registrations, connect all the
> > >> + * pools previously created. Also enable further pools to be connected
> > >> + * right away.
> > >> + */
> > > 
> > > This does not seem as kernel-doc comment. Please either remove the second *
> > > from the opening comment mark or reformat the comment.
> > 
> > For this too, I thought I had caught them all, but I was wrong ...
> > 
> > I didn't find any mention of automated checking for comments.
> > Is there such tool?
> 
> I don't know if there is a tool. I couldn't find anything in scripts, maybe
> somebody have such tool out of tree.
> 
> For now, I've added mm-api.rst that includes all mm .c files and run 'make
> htmldocs' which spits plenty of warnings and errors.

Actually, you can run 'scripts/kernel-doc -v -none <filename>' to check
comments starting with '/**'. I afraid it won't catch formatted blocks that
start with '/*'
 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
