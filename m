Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l9OJLeB7025222
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 20:21:41 +0100
Received: from rv-out-0910.google.com (rvfc24.prod.google.com [10.140.180.24])
	by zps75.corp.google.com with ESMTP id l9OJLLRd020215
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 12:21:40 -0700
Received: by rv-out-0910.google.com with SMTP id c24so260467rvf
        for <linux-mm@kvack.org>; Wed, 24 Oct 2007 12:21:40 -0700 (PDT)
Message-ID: <b040c32a0710241221m9151f6xd0fe09e00608a597@mail.gmail.com>
Date: Wed, 24 Oct 2007 12:21:40 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
In-Reply-To: <1193252583.18417.52.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132345.13013.36192.stgit@kernel>
	 <1193251414.4039.14.camel@localhost>
	 <1193252583.18417.52.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 10/24/07, Adam Litke <agl@us.ibm.com> wrote:
> On Wed, 2007-10-24 at 11:43 -0700, Dave Hansen wrote:
> > This particular nugget is for MAP_PRIVATE pages only, right?  The shared
> > ones should have another ref out on them for the 'mapping' too, so won't
> > get released at unmap, right?
>
> Yep that's right.  Shared pages are released by truncate_hugepages()
> when the ref for the mapping is dropped.

I think as a follow up patch, we should debit the quota in
free_huge_page(), so you don't have to open code it like this and also
consolidate calls to hugetlb_put_quota() in one place.  It's cleaner
that way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
