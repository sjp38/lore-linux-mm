Message-ID: <3D6FEAAF.E30967AD@zip.com.au>
Date: Fri, 30 Aug 2002 14:59:11 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: Avoiding the highmem mess
References: <0334AD85-BC63-11D6-B00B-000393829FA4@cs.amherst.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Scott Kaplan wrote:
> 
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> ...
> Is there an easy way to avoid ZONE_HIGHMEM?  Is it as easy as avoiding
> machines that have more than 1 GB of physical memory so that only
> ZONE_NORMAL is used?

Sure.  Or just disable highmem in kernel config.

But be aware that since 2.5.32, the active/inactive lists are
per-zone.  So you only ever have one type of page on each list.
Probably, this will simplify things.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
