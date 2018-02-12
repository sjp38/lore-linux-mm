Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE6956B000A
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:36:45 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id f21so12834552qtm.11
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 03:36:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s62si6483404qkb.266.2018.02.12.03.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 03:36:45 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1CBZM3E030840
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:36:44 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g35j3jnga-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:36:43 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 12 Feb 2018 11:36:40 -0000
Date: Mon, 12 Feb 2018 13:36:33 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-2-igor.stoppa@huawei.com>
 <20180211122444.GB13931@rapoport-lnx>
 <f0a244f2-f63a-376b-28f2-debbe914da34@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0a244f2-f63a-376b-28f2-debbe914da34@huawei.com>
Message-Id: <20180212113633.GC20737@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Mon, Feb 12, 2018 at 01:17:01PM +0200, Igor Stoppa wrote:
> 
> 
> On 11/02/18 14:24, Mike Rapoport wrote:
> > On Sun, Feb 11, 2018 at 05:19:15AM +0200, Igor Stoppa wrote:
> [...]
> 
> >> +/**
> >> + * mem_to_units - convert references to memory into orders of allocation
> > 
> > Documentation/doc-guide/kernel-doc.rst recommends to to include brackets
> > for function comments. I haven't noticed any difference in the resulting
> > html, so I'm not sure if the brackets are actually required.
> 
> This is what I see in the example from mailine docs:
> 
> /**
>  * foobar() - Brief description of foobar.
>  * @argument1: Description of parameter argument1 of foobar.
>  * @argument2: Description of parameter argument2 of foobar.
>  *
>  * Longer description of foobar.
>  *
>  * Return: Description of return value of foobar.
>  */
> int foobar(int argument1, char *argument2)
> 
> 
> What are you referring to?
 
I'm referring to "foobar() - brief description" vs "foobar - brief
description".

The generated html looks exactly the same in the browser, so I don't know
if the brackets are really required.

> [...]
> 
> >> + * @size: amount in bytes
> >> + * @order: power of 2 represented by each entry in the bitmap
> >> + *
> >> + * Returns the number of units representing the size.
> > 
> > Please s/Return/Return:/
> 
> :-( I thought I had fixed them all. thanks for spotting this.
> 
> [...]
> 
> >> + * Return: If two users alter the same bit, to one it will return
> >> + * remaining entries, to the other it will return 0.
> > 
> > And what if there are three or four concurrent users? ;-)
> > 
> > I believe that a more elaborate description about what happens with
> > concurrent attempts to alter the bitmap would be really helpful.
> 
> ok
> 
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
