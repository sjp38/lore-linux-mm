Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6QKb9RX195402
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 16:37:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6QKb89v382168
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 14:37:08 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6QKb8OV005163
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 14:37:08 -0600
Subject: Re: Memory pressure handling with iSCSI
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050726121250.0ba7d744.akpm@osdl.org>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726111110.6b9db241.akpm@osdl.org>
	 <1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726114824.136d3dad.akpm@osdl.org>
	 <20050726121250.0ba7d744.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 26 Jul 2005 13:36:56 -0700
Message-Id: <1122410216.6433.41.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-07-26 at 12:12 -0700, Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > Can you please reduce the number of filesystems, see if that reduces the
> >  dirty levels?
> 
> Also, it's conceivable that ext3 is implicated here, so it might be saner
> to perform initial investigation on ext2.
> 
> (when kjournald writes back a page via its buffers, the page remains
> "dirty" as far as the VFS is concerned.  Later, someone tries to do a
> writepage() on it and we'll discover the buffers' cleanness and the page
> will be cleaned without any I/O being performed.  All the throttling
> _should_ work OK in this case.  But ext2 is more straightforward.)

I will try ext2 next.

- Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
