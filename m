Subject: Re: Swapping for diskless nodes
Date: Thu, 9 Aug 2001 16:19:49 +0100 (BST)
In-Reply-To: <no.id> from "Dirk W. Steinberg" at Aug 09, 2001 02:12:00 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15UrbB-0007T9-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Dirk W. Steinberg" <dws@dirksteinberg.de>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

> the memory of a fast server could have much less latency that writing 
> that page out to a local old, slow IDE disk. Clusters could even have
> special high-bandwidth, low latency networks that could be used for
> remote paging.
> 
> In a perfect world, all nodes in a cluster would be able to dynamically 
> share a pool of "cluster swap" space, so any locally available swap that
> is not used could be utilized by other nodes in the cluster.

That I think is a 2.5 problem. One thing that has been talked about several
times now is removing all the swap special case crap from the mm and making
swap a file system. That removes special cases and means anyone can write
or use custom, or multiple swap filesystems, in theory including things like
swap over a shared GFS pool

But its not for 2.4, no way

Alan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
