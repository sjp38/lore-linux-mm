Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4DE16B002E
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 10:32:08 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id d15so13370886qtg.2
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:32:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c16si1472251qka.364.2018.02.12.07.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 07:32:08 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1CFTrCt139514
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 10:32:07 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2g392kutc0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 10:32:07 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 12 Feb 2018 15:32:05 -0000
Date: Mon, 12 Feb 2018 17:31:57 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-5-igor.stoppa@huawei.com>
 <20180211123743.GC13931@rapoport-lnx>
 <e7ea02b4-3d43-9543-3d14-61c27e155042@huawei.com>
 <20180212114310.GD20737@rapoport-lnx>
 <20180212125347.GE20737@rapoport-lnx>
 <68edadf0-2b23-eaeb-17de-884032f0b906@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <68edadf0-2b23-eaeb-17de-884032f0b906@huawei.com>
Message-Id: <20180212153156.GF20737@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Mon, Feb 12, 2018 at 03:41:57PM +0200, Igor Stoppa wrote:
> 
> 
> On 12/02/18 14:53, Mike Rapoport wrote:
> > 'scripts/kernel-doc -v -none 
> 
> That has a quite interesting behavior.
> 
> I run it on genalloc.c while I am in the process of adding the brackets
> to the function names in the kernel-doc description.
> 
> The brackets confuse the script and it fails to output the name of the
> function in the log:
> 
> lib/genalloc.c:123: info: Scanning doc for get_bitmap_entry
> lib/genalloc.c:139: info: Scanning doc for
> lib/genalloc.c:152: info: Scanning doc for
> lib/genalloc.c:164: info: Scanning doc for

 
> 
> The first function does not have the brackets.
> The others do. So what should I do with the missing brackets?
> Add them, according to the kernel docs, or leave them out?

Seems that kernel-doc does not consider () as a valid match for the
identifier :)
 
Can you please check with the below patch?

> I'd lean toward adding them.
> 
> --
> igor
 
-- 
Sincerely yours,
Mike.
