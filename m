Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id l6O0NMea013248
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:23:22 -0700
Received: from an-out-0708.google.com (anac3.prod.google.com [10.100.54.3])
	by zps19.corp.google.com with ESMTP id l6O0NIZX019858
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:23:18 -0700
Received: by an-out-0708.google.com with SMTP id c3so328611ana
        for <linux-mm@kvack.org>; Mon, 23 Jul 2007 17:23:18 -0700 (PDT)
Message-ID: <b040c32a0707231723h5411bb25oa56834f68457020e@mail.gmail.com>
Date: Mon, 23 Jul 2007 17:23:18 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: hugepage test failures
In-Reply-To: <46A50FD0.2020001@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070723120409.477a1c31.randy.dunlap@oracle.com>
	 <29495f1d0707231318n5e76d141t5f81431ead007b53@mail.gmail.com>
	 <46A50FD0.2020001@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/07, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> > They are kept uptodate, at least.
>
> You mean that the Doc/ tree is not kept up to date?  ;(

AFAICT, the sample code in Documentation/vm/hugetlbpage.txt is up to
date.  I'm not aware any bug in the user space example code (except
maybe the memory segment LENGTH is too big at 256MB).  If there are
bugs there, I would like to hear about it.


> But this represents an R*word (regression).
> These tests ran successfully until recently (I can't say when).

Yeah, it's a true regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
