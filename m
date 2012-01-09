Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id A59DF6B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 18:26:50 -0500 (EST)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 9 Jan 2012 18:26:49 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q09NQh1b317926
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 18:26:43 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q09NQhVN021181
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 18:26:43 -0500
Message-ID: <4F0B77AF.1060005@linux.vnet.ibm.com>
Date: Mon, 09 Jan 2012 17:26:39 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] staging: zsmalloc: memory allocator for compressed
 pages
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120109230944.GA11802@suse.de>
In-Reply-To: <20120109230944.GA11802@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/09/2012 05:09 PM, Greg KH wrote:
> On Mon, Jan 09, 2012 at 04:51:55PM -0600, Seth Jennings wrote:
>> This patchset introduces a new memory allocation library named
>> zsmalloc.  zsmalloc was designed to fulfill the needs
>> of users where:
>>  1) Memory is constrained, preventing contiguous page allocations
>>     larger than order 0 and
>>  2) Allocations are all/commonly greater than half a page.
> 
> As this is submitted during the merge window, I don't have any time to
> look at it until after 3.3-rc1 is out.
> 
> I'll queue it up for then.

Thanks Greg!

I forgot to specify in the cover letter, this patch is based on
v3.2 PLUS my zv stat fix (https://lkml.org/lkml/2011/12/30/48) 
and crypto API support patch v2 (https://lkml.org/lkml/2012/1/3/263).
Both have been Acked by Dan and Nitin had Acked v1 of the crypto API
support patch. Everything should merge cleanly if applied in that
order.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
