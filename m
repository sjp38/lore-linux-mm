Message-ID: <3A9ED281.90C5F7CB@dm.ultramaster.com>
Date: Thu, 01 Mar 2001 17:51:45 -0500
From: David Mansfield <lkml@dm.ultramaster.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom-killer trigger
References: <Pine.LNX.4.33.0103011904140.1304-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org,  =?iso-8859-1?Q?Xos=C9=20V=E1zquez?= <xose@smi-ps.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> 1. the OOM killer never triggers if we have > freepages.min
>    of free memory
> 2. __alloc_pages() never allocates pages to < freepages.min
>    for user allocations
> 
> ==> the OOM killer never gets triggered under some workloads;
>     the system just sits around with nr_free_pages == freepages.min
> 
> The patch below trivially fixes this by upping the OOM kill limit
> by a really small number of pages ...

> +       if (nr_free_pages() > freepages.min + 4)


Call me stupid, but why not just change the > to >= (or < to <=) rather
than introducing a magic number (4).  Or at least make the magic number
interesting, like:

+       if (nr_free_pages() > freepages.min + 42)

:-)

Thanks for the bugfix,
David

-- 
David Mansfield                                           (718) 963-2020
david@ultramaster.com
Ultramaster Group, LLC                               www.ultramaster.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
