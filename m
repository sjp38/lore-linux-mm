Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 45A5A6B0068
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 12:11:22 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 2 Oct 2012 12:11:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q92GBFBO34799658
	for <linux-mm@kvack.org>; Tue, 2 Oct 2012 12:11:15 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q92GBEOB020845
	for <linux-mm@kvack.org>; Tue, 2 Oct 2012 12:11:15 -0400
Message-ID: <506B121E.8090307@linux.vnet.ibm.com>
Date: Tue, 02 Oct 2012 11:11:10 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] zcache2 on PPC64 (Was: [RFC] mm: add support for
 zsmalloc and zcache)
References: <30a570e8-8157-47e1-867a-4960a7c1173d@default> <20120928133121.GH29125@suse.de>
In-Reply-To: <20120928133121.GH29125@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

On 09/28/2012 08:31 AM, Mel Gorman wrote:
> On Tue, Sep 25, 2012 at 04:31:01PM -0700, Dan Magenheimer wrote:
>> Attached patch applies to staging-next and I _think_ should
>> fix the reported problem where zbud in zcache2 does not
>> work on a PPC64 with PAGE_SIZE!=12.  I do not have a machine
>> to test this so testing by others would be appreciated.
>>
> 
> Seth, can you verify?

Yes, this patch does prevent the crash on PPC64.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
