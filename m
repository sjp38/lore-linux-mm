Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id CAC7A6B0343
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 09:50:12 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 09:50:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C07E96E81B5
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 09:48:34 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PDmXiQ146786
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 09:48:34 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PDmIfR015421
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 07:48:18 -0600
Message-ID: <4FE86C1D.2020302@linux.vnet.ibm.com>
Date: Mon, 25 Jun 2012 08:48:13 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] zcache: fix preemptable memory allocation in atomic
 context
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE36D32.3030408@linux.vnet.ibm.com> <20120623030052.GA18440@kroah.com>
In-Reply-To: <20120623030052.GA18440@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/22/2012 10:00 PM, Greg Kroah-Hartman wrote:
> On Thu, Jun 21, 2012 at 01:51:30PM -0500, Seth Jennings wrote:
>> I just noticed you sent this patchset to Andrew, but the
>> staging tree is maintained by Greg.  You're going to want to
>> send these patches to him.
>>
>> Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> 
> After this series is redone, right?  As it is, this submission didn't
> look ok, so I'm hoping a second round is forthcoming...

Yes. That is the cleanest way since there are dependencies
among the patches.  You could pull 04-08 and be ok, but you
might just prefer a repost.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
