Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C364C6B01BD
	for <linux-mm@kvack.org>; Sun, 30 May 2010 14:15:55 -0400 (EDT)
Received: by pzk28 with SMTP id 28so3163718pzk.11
        for <linux-mm@kvack.org>; Sun, 30 May 2010 11:15:53 -0700 (PDT)
Message-ID: <4C02AB5A.5000706@vflare.org>
Date: Sun, 30 May 2010 23:45:54 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH V2 0/4] Frontswap (was Transcendent Memory): overview
References: <20100528174020.GA28150@ca-server1.us.oracle.com>
In-Reply-To: <20100528174020.GA28150@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com, avi@redhat.com, pavel@ucw.cz, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On 05/28/2010 11:10 PM, Dan Magenheimer wrote:
> [PATCH V2 0/4] Frontswap (was Transcendent Memory): overview
> 
> Changes since V1:
> - Rebased to 2.6.34 (no functional changes)
> - Convert to sane types (per Al Viro comment in cleancache thread)
> - Define some raw constants (Konrad Wilk)
> - Performance analysis shows significant advantage for frontswap's
>   synchronous page-at-a-time design (vs batched asynchronous speculated
>   as an alternative design).  See http://lkml.org/lkml/2010/5/20/314
> 

I think zram (http://lwn.net/Articles/388889/) is a more generic solution
and can also achieve swap-to-hypervisor as a special case.

zram is a generic in-memory compressed block device. To get frontswap
functionality, such a device (/dev/zram0) can be exposed to a VM as
a 'raw disk'. Such a disk can be used for _any_ purpose by the guest,
including use as a swap disk.

This method even works for Windows guests. Please see:
http://www.vflare.org/2010/05/compressed-ram-disk-for-windows-virtual.html

Here /dev/zram0 of size 2GB was created and exposed to Windows VM as a
'raw disk' (using VirtualBox). This disk was detected in the guest and NTFS
filesystem was created on it (Windows cannot swap directly to a partition;
it always uses swap file(s)). Then Windows was configured to swap over a
file in this drive.

Obviously, the same can be done with Linux guests. Thus, zram is useful
in both native and virtualized environments with different use cases.


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
