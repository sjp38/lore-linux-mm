Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m1KBtJ5h003617
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:55:19 -0800
Received: from py-out-1112.google.com (pygw53.prod.google.com [10.34.224.53])
	by zps75.corp.google.com with ESMTP id m1KBtI8o011244
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:55:19 -0800
Received: by py-out-1112.google.com with SMTP id w53so3205926pyg.25
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:55:18 -0800 (PST)
Message-ID: <6599ad830802200355v40bf8b81re32c24cefad0b279@mail.gmail.com>
Date: Wed, 20 Feb 2008 03:55:18 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BC10A8.4020508@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	 <Pine.LNX.4.64.0802191449490.6254@blonde.site>
	 <47BBC15E.5070405@linux.vnet.ibm.com>
	 <20080220.185821.61784723.taka@valinux.co.jp>
	 <47BC10A8.4020508@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Feb 20, 2008 3:36 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >
> > And you may possibly have a chance to remove page->page_cgroup member
> > if you allocate array of page_cgroups and attach them to the zone which
> > the pages belong to.
> >
>
> We thought of this as well. We dropped it, because we need to track only user
> pages at the moment. Doing it for all pages means having the overhead for each
> page on the system.
>

While having an array of page_cgroup objects may or may not be a good
idea, I'm not sure that the overhead argument against them is a very
good one.

I suspect that on most systems that want to use the cgroup memory
controller, user-allocated pages will fill the vast majority of
memory. So using the arrays and eliminating the extra pointer in
struct page would actually reduce overhead.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
