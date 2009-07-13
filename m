Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E30F6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:52:24 -0400 (EDT)
Date: Mon, 13 Jul 2009 16:17:45 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for
	Linux
Message-ID: <20090713201745.GA3783@think>
References: <a09e4489-a755-46e7-a569-a0751e0fc39f@default> <4A5A1A51.2080301@redhat.com> <4A5A3AC1.5080800@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A5A3AC1.5080800@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Avi Kivity <avi@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 12, 2009 at 02:34:25PM -0500, Anthony Liguori wrote:
> Avi Kivity wrote:
>>
>> In fact CMM2 is much more intrusive (but on the other hand provides  
>> much more information).
> I don't think this will remain true long term.  CMM2 touches a lot of  
> core mm code and certainly qualifies as intrusive.  However the result  
> is that the VMM has a tremendous amount of insight into how the guest is  
> using it's memory and can implement all sorts of fancy policy for  
> reclaim.  Since the reclaim policy can evolve without any additional  
> assistance from the guest, the guest doesn't have to change as policy  
> evolves.
>
> Since tmem requires that reclaim policy is implemented within the guest,  
> I think in the long term, tmem will have to touch a broad number of  
> places within Linux.  Beside the core mm, the first round of patches  
> already touch filesystems (just ext3 to start out with).  To truly be  
> effective, tmem would have to be a first class kernel citizen and I  
> suspect a lot of code would have to be aware of it.

This depends on the extent to which tmem is integrated into the VM.  For
filesystem usage, the hooks are relatively simple because we already
have a lot of code sharing in this area.  Basically tmem is concerned
with when we free a clean page and when the contents of a particular
offset in the file are no longer valid.

The nice part about tmem is that any time a given corner case gets
tricky, you can just invalidate that offset in tmem and move on.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
