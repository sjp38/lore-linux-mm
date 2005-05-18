Date: Wed, 18 May 2005 16:23:02 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page flags ?
Message-Id: <20050518162302.13a13356.akpm@osdl.org>
In-Reply-To: <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	<20050518145644.717afc21.akpm@osdl.org>
	<1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> Is it possible to get yet another PG_fs_specific flag ? 

Anything's possible ;)

How many bits are spare now?  ZONETABLE_PGSHIFT hurts my brain.

> Reasons for it are:
> 
> 	- I need this for supporting delayed allocation on ext3.

Why?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
