Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4IN0ImD702854
	for <linux-mm@kvack.org>; Wed, 18 May 2005 19:00:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4IN0I1o157426
	for <linux-mm@kvack.org>; Wed, 18 May 2005 17:00:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4IN0I0h009707
	for <linux-mm@kvack.org>; Wed, 18 May 2005 17:00:18 -0600
Subject: Re: page flags ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050518145644.717afc21.akpm@osdl.org>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518145644.717afc21.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 18 May 2005 15:42:25 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-05-18 at 14:56, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > Does anyone know what this page-flag is used for ? I see some
> > references to this in AFS. 
> > 
> > Is it possible for me to use this for my own use in ext3 ? 
> > (like delayed allocations ?) Any generic routines/VM stuff
> > expects me to use this only for a specific purpose ?
> > 
> > #define PG_fs_misc               9      /* Filesystem specific bit */
> > 
> 
> It's identical to PG_checked, added by David Howells'
> provide-a-filesystem-specific-syncable-page-bit.patch
> 
> IIRC we decided to expand the definition of PG_checked to mean
> "a_ops-private, fs-defined page flag".  I guess if/when that patch is
> merged we'll do a kernel-wide s/PG_checked/PG_fs_misc/.
> 
> And ext3 is already using that flag.

:(

Is it possible to get yet another PG_fs_specific flag ? 
Reasons for it are:

	- I need this for supporting delayed allocation on ext3. Me, Ted
	  and Suparna thought about it for a while to see we can 
	  workaround it. So far, I haven't found a clean way.

	- useful for other folks currently overloading page->private
	  for this purpose. May be then, we can make most filesystems
	  use mpage routines (since they assume page->private is for
	  bufferheads ?)

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
