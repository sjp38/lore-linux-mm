Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 00D866B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 21:54:22 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so291224501pfy.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:54:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s5si25214295pgg.177.2017.01.25.18.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 18:54:21 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0Q2n26o111440
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 21:54:20 -0500
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com [125.16.236.5])
	by mx0a-001b2d01.pphosted.com with ESMTP id 286xbry5jh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 21:54:20 -0500
Received: from localhost
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 26 Jan 2017 08:24:16 +0530
Received: from d28relay10.in.ibm.com (d28relay10.in.ibm.com [9.184.220.161])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 2F0D7E0024
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:25:29 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0Q2rLYs26869978
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:23:21 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0Q2sCHd011293
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:24:13 +0530
Date: Wed, 25 Jan 2017 18:54:08 -0800
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
 <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
 <20170124222217.GB19920@node.shutemov.name>
 <20170125165522.GA11569@linux.vnet.ibm.com>
 <20170125183510.GB17286@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20170125183510.GB17286@cmpxchg.org>
Message-Id: <20170126025408.GB11569@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

> > 
> > The first time the breakpoint is hit on a page, it replaces the text
> > page with anon page.  Now lets assume we insert breakpoints in all the
> > pages in a range. Here each page is individually replaced by a non THP
> > anonpage. (since we dont have bulk breakpoint insertion support,
> > breakpoint insertion happens one at a time). Now the only interesting
> > case may be when each of these replaced pages happen to be physically
> > contiguous so that THP kicks in to replace all of these pages with one
> > THP page. Can happen in practice?
> > 
> > Are there any other cases that I have missed?
> 
> We use a hack in our applications where we open /proc/self/maps, copy
> text segments to a staging area, then create overlay anon mappings on
> top and copy the text back into them. Now we have THP-backed text and
> very little iTLB pressure :-)
> 
> That said, we haven't run into the uprobes issue yet.
> 

Thanks Johannes, Kirill, Rik.


Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
