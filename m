Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7718A6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 15:17:08 -0400 (EDT)
Received: by gxk3 with SMTP id 3so3243454gxk.14
        for <linux-mm@kvack.org>; Sun, 12 Jul 2009 12:34:28 -0700 (PDT)
Message-ID: <4A5A3AC1.5080800@codemonkey.ws>
Date: Sun, 12 Jul 2009 14:34:25 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <a09e4489-a755-46e7-a569-a0751e0fc39f@default> <4A5A1A51.2080301@redhat.com>
In-Reply-To: <4A5A1A51.2080301@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
>
> In fact CMM2 is much more intrusive (but on the other hand provides 
> much more information).
I don't think this will remain true long term.  CMM2 touches a lot of 
core mm code and certainly qualifies as intrusive.  However the result 
is that the VMM has a tremendous amount of insight into how the guest is 
using it's memory and can implement all sorts of fancy policy for 
reclaim.  Since the reclaim policy can evolve without any additional 
assistance from the guest, the guest doesn't have to change as policy 
evolves.

Since tmem requires that reclaim policy is implemented within the guest, 
I think in the long term, tmem will have to touch a broad number of 
places within Linux.  Beside the core mm, the first round of patches 
already touch filesystems (just ext3 to start out with).  To truly be 
effective, tmem would have to be a first class kernel citizen and I 
suspect a lot of code would have to be aware of it.

So while CMM2 does a lot of code no one wants to touch, I think in the 
long term it would remain relatively well contained compared to tmem 
which will steadily increase in complexity within the guest.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
