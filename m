Date: Thu, 11 Apr 2002 18:08:47 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Memory allocation in Linux (fwd)
Message-ID: <20020411180847.E20895@redhat.com>
References: <3CAC3E85.2040304@earthlink.net> <Pine.LNX.4.21.0204111756220.26014-100000@mailhost.tifr.res.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0204111756220.26014-100000@mailhost.tifr.res.in>; from amitjain@tifr.res.in on Thu, Apr 11, 2002 at 06:16:56PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Amit S. Jain" <amitjain@tifr.res.in>
Cc: Joseph A Knapka <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2002 at 06:16:56PM +0530, Amit S. Jain wrote:
> Hi everyone,
>             This is a continuation of the mail I had written earlier (see
> down)tellin bout my problem that when i use vmalloc()...I get an error stating
>  "PCI bus error 2290".I think i have a slight idea what the problem could
> be.....Hope u all could comment on it.
> The large amount of memory i obtain using vmalloc is then pointed to by
> the skb "network" buffers as i copy data into this memory which has to be
> transmitted.Since the memory is discontinuous implying data is
> discontinuous and the ethernet card I am using is REALTEK8139 which
> doesnot support SCATTER/GATHER DMA.... hence the PCI bus cant find the
> continuous data which has to be transmitted.

You cannot pass address returned from vmalloc to hardware: vmalloc returns 
a virtual mapping of memory.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
