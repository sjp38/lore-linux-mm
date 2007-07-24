Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l6O027WE024165
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:02:07 -0700
Received: from an-out-0708.google.com (ancc31.prod.google.com [10.100.29.31])
	by zps75.corp.google.com with ESMTP id l6O0246T026381
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:02:04 -0700
Received: by an-out-0708.google.com with SMTP id c31so336135anc
        for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:02:04 -0700 (PDT)
Message-ID: <b040c32a0707231702w622a10d4y18a6e127776ae7df@mail.gmail.com>
Date: Mon, 23 Jul 2007 17:02:04 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: hugepage test failures
In-Reply-To: <20070723120409.477a1c31.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070723120409.477a1c31.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/07, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> I'm a few hundred linux-mm emails behind, so maybe this has been
> addressed already.  I hope so.
>
> I run hugepage-mmap and hugepage-shm tests (from Doc/vm/hugetlbpage.txt)
> on a regular basis.  Lately they have been failing, usually with -ENOMEM,
> but sometimes the mmap() succeeds and hugepage-mmap gets a SIGBUS:

man, what did people do to hugetlb?

In dequeue_huge_page(), it just loops around for all the alloc'able
zones, even though this function is suppose to just allocate *ONE*
hugetlb page.  That is a serious memory leak here.  We need a break
statement in the inner if statement there.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
