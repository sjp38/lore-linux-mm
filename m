Received: from frejya.corp.netapp.com (frejya.corp.netapp.com [10.10.20.91])
	by mx01-a.netapp.com (8.11.1/8.11.1/NTAP-1.2) with ESMTP id f4N1VUK05733
	for <linux-mm@kvack.org>; Tue, 22 May 2001 18:31:34 -0700 (PDT)
Received: from ussvlexc06.corp.netapp.com (localhost [127.0.0.1])
	by frejya.corp.netapp.com (8.11.1/8.11.1/NTAP-1.2) with ESMTP id f4N1VUm12039
	for <linux-mm@kvack.org>; Tue, 22 May 2001 18:31:30 -0700 (PDT)
From: "Chuck Lever" <cel@netapp.com>
Subject: RE: vm_enough_memory() and RAM disks
Date: Tue, 22 May 2001 21:32:33 -0400
Message-ID: <NFBBLKEIKLGDCJAAAEKOKEDPCAAA.cel@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-Reply-To: <3B0ACB08.C9032ADB@mvista.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

i've noticed a (possibly) related problem.

i've configured an NFS server to export a largish RAM disk for
the purposes of testing NFS performance.  the RAM disk is half
as large as the server's physical memory.  i've seen several
times that when the machine runs out of memory (the "free"
column in vmstat output goes below 1M) and the kernel wants
to swap, the system freezes up.  my theory was that something
was attempting to flush buffers, but because the buffers were
bh_protected (because they were part of a large RAM disk), the
kernel wasn't successful at making any normal headway, and so
it looped.

> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org]On
> Behalf Of Scott Anderson
> Sent: Tuesday, May 22, 2001 4:25 PM
> To: linux-mm@kvack.org
> Subject: vm_enough_memory() and RAM disks
> 
> 
> I've noticed that vm_enough_memory() does not account for the
> fact that buffer cache could be used for RAM disks.  It appears that it
> assumes that all of buffer cache is only being used for caching data
> from disk drives and could be freed up as needed.  Logically, I think
> what needs to happen is that the amount of space occupied by buffers
> with BH_Protected needs to be subtracted off of buffermem_pages.
> 
> As you can well imagine, in small systems with relatively large RAM
> disks, this does not lead to good behavior...
> 
> Now for the true confession: I'm not finding time to come up with a
> patch for this right now.  However, I thought it would be better to at
> least get this out instead of waiting around for me to find the time.
> 
> Thanks for listening,
>     Scott Anderson
>     scott_anderson@mvista.com   MontaVista Software Inc.
>     (408)328-9214               1237 East Arques Ave.
>     http://www.mvista.com       Sunnyvale, CA  94085
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
