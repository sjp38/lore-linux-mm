Date: Thu, 13 Apr 2000 09:07:46 +0300
From: Matti Aarnio <matti.aarnio@sonera.fi>
Subject: Re: page->offset
Message-ID: <20000413090746.R13396@mea.tmt.tele.fi>
References: <CA2568C0.001B9300.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
In-Reply-To: <CA2568C0.001B9300.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Thu, Apr 13, 2000 at 10:23:03AM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 13, 2000 at 10:23:03AM +0530, pnilesh@in.ibm.com wrote:
> I think I had put up the question in a wrong way.
> 
> If I mmap a file from/at a particular offset.
>   char *p;
>   fd = open("anyfile");
>   p = mmap (NULL,100,PROT_READ|PROT_WRITE, MAP_SHARED,fd,10);
> 
> Here the call fails .
> I tried to map at / from offset 512 that also failed.
> however with the offset of 1024 it succeded.
>
> So I can not mmap anything which is not fs block size aligned .

	Actually you should not be able to map anything which is
	not MACHINE PAGE SIZE aligned -- not map shared, that is.
	It is somewhat accidental that 2.2 allows FS block size
	alignment.   A  MAP_PRIVATE  may allow other offsets.

	In 2.4 the 'page->offset' field is gone, and it is known
	as 'page->index', which is scaled version of offset value.
	Scaled with PAGE SIZE.

	Reason for going to this has been (among others) to get
	coherency into the page cache so that there won't be
	differently aligned copies of same byte range in the memory.

> Nilesh

/Matti Aarnio
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
