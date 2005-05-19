Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4JNqXua444192
	for <linux-mm@kvack.org>; Thu, 19 May 2005 19:52:33 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JNqXcs253662
	for <linux-mm@kvack.org>; Thu, 19 May 2005 17:52:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4JNqWmU032694
	for <linux-mm@kvack.org>; Thu, 19 May 2005 17:52:32 -0600
Subject: Re: page flags ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050519155306.2b895e64.akpm@osdl.org>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518145644.717afc21.akpm@osdl.org>
	 <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518162302.13a13356.akpm@osdl.org> <428C6FB9.4060602@shadowen.org>
	 <20050519041116.1e3a6d29.akpm@osdl.org>
	 <1116527349.26913.1353.camel@dyn318077bld.beaverton.ibm.com>
	 <20050519155306.2b895e64.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1116545665.26913.1378.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 19 May 2005 16:34:27 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: apw@shadowen.org, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-05-19 at 15:53, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > I am worried about the overhead this might add to kmap/kunmap().
> > 
> 
> kmap() already sucks.
> 

I thought so, but wanted to be explicit.

> >  -#define PG_highmem		 8
> >  +#define PG_highmem_removed	 8	/* Trying to kill this */
> 
> I thnik I'll just nuke this.

Yep. I was just trying to be nice - if some one gets a compile failure,
i wanted them to know that "we are trying to remove it, justify your
case".

BTW, I tried to kill PG_slab. Other than catching error conditions
with memory freeing, there are few users of it
 
	-  show_mem(): to show how much memory stuck in slab easily.
	-  kobjsize()
Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
