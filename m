Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA1FZaP5021060
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 11:35:36 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA1FZRMx076494
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 09:35:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA1FZRT9015264
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 09:35:27 -0600
Subject: Re: migratepage failures on reiserfs
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071031134006.2ecd520b@think.oraclecorp.com>
References: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030135442.5d33c61c@think.oraclecorp.com>
	 <1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030185840.48f5a10b@think.oraclecorp.com>
	 <1193847261.17412.13.camel@dyn9047017100.beaverton.ibm.com>
	 <20071031134006.2ecd520b@think.oraclecorp.com>
Content-Type: text/plain
Date: Thu, 01 Nov 2007 08:38:57 -0800
Message-Id: <1193935137.26106.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 13:40 -0400, Chris Mason wrote:
> On Wed, 31 Oct 2007 08:14:21 -0800
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > 
> > I tried data=writeback mode and it didn't help :(
> 
> Ouch, so much for the easy way out.
> 
> > 
> > unable to release the page 262070
> > bh c0000000211b9408 flags 110029 count 1 private 0
> > unable to release the page 262098
> > bh c000000020ec9198 flags 110029 count 1 private 0
> > memory offlining 3f000 to 40000 failed
> > 
> 
> The only other special thing reiserfs does with the page cache is file
> tails.  I don't suppose all of these pages are index zero in files
> smaller than 4k?

Ahhhhhhhhhhhhh !! I am so blind :(

I have been suspecting reiserfs all along, since its executing
fallback_migrate_page(). Actually, these buffer heads are
backing blockdev. I guess these are metadata buffers :( 
I am not sure we can do much with these..

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
