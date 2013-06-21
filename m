Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E24A26B0033
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 10:48:03 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 08:47:32 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 07F361FF0022
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 08:42:14 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5LElMcu152118
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 08:47:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5LElM7B011738
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 08:47:22 -0600
Date: Fri, 21 Jun 2013 09:47:19 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] zswap: update/document boot parameters
Message-ID: <20130621144719.GC3558@cerebellum>
References: <1371716949-9918-1-git-send-email-bob.liu@oracle.com>
 <20130620144826.GB9461@cerebellum>
 <20130620235109.GA29127@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130620235109.GA29127@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com, Bob Liu <bob.liu@oracle.com>

On Fri, Jun 21, 2013 at 07:51:09AM +0800, Wanpeng Li wrote:
> Do you plan to do zswap modulization? Otherwise I am happy to do that.
> ;-)

The question really isn't _can_ it be done.  It really is as simple as
exporting some swap symbols from the kernel.  The question is can it be done
_cleanly_.  I, for one, haven't seen a way to do it cleanly.

I guess there is also the question, "what is the benefit of having it as a
module?" and "could it restrict future functionality?" i.e. tighter integration
with the VMM.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
