Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id l9QGpeO9010823
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 17:51:40 +0100
Received: from nf-out-0910.google.com (nfhf5.prod.google.com [10.48.233.5])
	by zps18.corp.google.com with ESMTP id l9QGocpF016580
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:51:39 -0700
Received: by nf-out-0910.google.com with SMTP id f5so666214nfh
        for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:51:38 -0700 (PDT)
Message-ID: <d43160c70710260951q351a6864ye5bb49e1b8a96aa3@mail.gmail.com>
Date: Fri, 26 Oct 2007 12:51:38 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/POC Make Page Tables Relocatable
In-Reply-To: <20071026161007.GA19443@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <20071026161007.GA19443@skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On 10/26/07, Mel Gorman <mel@skynet.ie> wrote:
> I suspect this might be overkill from a memory fragmentation
> perspective. When grouping pages by mobility, page table pages are
> currently considered MIGRATE_UNMOVABLE. From what I have seen, they are

I may be being dense, but the page migration code looks to me like it
just moves pages in a process from one node to another node with no
effort to touch the page tables.  It would be easy to hook the code I
wrote into the page migration code, what I don't understand is when
the page tables should be migrated?  Only when the whole process is
being migrated?  When all the pages pointed to a page table are being
migrated?  When any page pointed to by the page table is being
migrated?


    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
