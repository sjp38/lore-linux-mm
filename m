Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 7B0F46B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 09:42:22 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 22 May 2012 07:42:19 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2DB84C90067
	for <linux-mm@kvack.org>; Tue, 22 May 2012 09:42:11 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4MDgDw7070746
	for <linux-mm@kvack.org>; Tue, 22 May 2012 09:42:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4MJD6nQ027304
	for <linux-mm@kvack.org>; Tue, 22 May 2012 15:13:06 -0400
Message-ID: <4FBB97B2.6050408@linux.vnet.ibm.com>
Date: Tue, 22 May 2012 08:42:10 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] zsmalloc: use unsigned long instead of void *
References: <1337567013-4741-1-git-send-email-minchan@kernel.org> <4FBA4EE2.8050308@linux.vnet.ibm.com>
In-Reply-To: <4FBA4EE2.8050308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On 05/21/2012 09:19 AM, Seth Jennings wrote:

> On 05/20/2012 09:23 PM, Minchan Kim wrote:
> 
>> We should use unsigned long as handle instead of void * to avoid any
>> confusion. Without this, users may just treat zs_malloc return value as
>> a pointer and try to deference it.
> 
> 
> I wouldn't have agreed with you about the need for this change as people
> should understand a void * to be the address of some data with unknown
> structure.
> 
> However, I recently discussed with Dan regarding his RAMster project
> where he assumed that the void * would be an address, and as such,
> 4-byte aligned.  So he has masked two bits into the two LSBs of the
> handle for RAMster, which doesn't work with zsmalloc since the handle is
> not an address.
> 
> So really we do need to convey as explicitly as possible to the user
> that the handle is an _opaque_ value about which no assumption can be made.


Wasn't really clear here.  All that to say, I think we do need this patch.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
