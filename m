Received: from [10.14.178.48]([10.14.178.48]) (1035 bytes) by megami
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m18O0Gr-0000xDC@megami>
	for <linux-mm@kvack.org>; Mon, 16 Dec 2002 10:47:17 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Mon, 16 Dec 2002 18:48:38 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: /proc/meminfo:MemShared
In-Reply-To: <3DFD9574.38F86231@digeo.com>
Message-ID: <Pine.LNX.4.44.0212161842020.11337-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Dec 2002, Andrew Morton wrote:
> Can anyone think of anything useful to print out here,
> or should it just be removed?

I'm in favour of just removing it.  2.4-ac went through a phase
of reporting tmpfs' shmem_nrpages (in kB) there; but it was an
entirely different meaning for MemShared, needs the releasepage
infrastructure of 2.4-ac for proper accounting (which I've never
cared to ask for in mainline); and 2.4.20-ac always says 0 like
everyone else.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
