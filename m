Date: Wed, 15 Nov 2000 15:34:58 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Question about pte_alloc()
Message-ID: <20001115153458.G3186@redhat.com>
References: <OF9A0A3560.2E2B9BC3-ON86256998.0052EDF0@hou.us.ray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF9A0A3560.2E2B9BC3-ON86256998.0052EDF0@hou.us.ray.com>; from Mark_H_Johnson@Raytheon.com on Wed, Nov 15, 2000 at 09:20:52AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux MM <linux-mm@kvack.org>, owner-linux-mm@kvack.org, Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Nov 15, 2000 at 09:20:52AM -0600, Mark_H_Johnson@Raytheon.com wrote:
> 
> Could you please clarify what is meant by...
>   "You cannot safely play pte games at interrupt time.  You _must_
> do this in the foreground."
> We are concerned because it may block adoption of Linux for one of our
> current applications.

...

>  - Can we do this kind of manipulation with the page tables if we modified
> the Linux trap handlers?

Trap handlers are completely different.  Page faults already vector
through the trap handlers, and the kernel is quite happy about
performing blocking IO or pte modifications in that context.  You
shouldn't have a problem as long as you observe the kernel's VM and
page table locking rules.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
