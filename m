Date: Thu, 19 May 2005 15:53:06 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page flags ?
Message-Id: <20050519155306.2b895e64.akpm@osdl.org>
In-Reply-To: <1116527349.26913.1353.camel@dyn318077bld.beaverton.ibm.com>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	<20050518145644.717afc21.akpm@osdl.org>
	<1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
	<20050518162302.13a13356.akpm@osdl.org>
	<428C6FB9.4060602@shadowen.org>
	<20050519041116.1e3a6d29.akpm@osdl.org>
	<1116527349.26913.1353.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: apw@shadowen.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> I am worried about the overhead this might add to kmap/kunmap().
> 

kmap() already sucks.

>  -#define PG_highmem		 8
>  +#define PG_highmem_removed	 8	/* Trying to kill this */

I thnik I'll just nuke this.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
