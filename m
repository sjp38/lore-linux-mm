Date: Thu, 12 Oct 2000 19:06:32 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: mix-block size for raw_io ??
Message-ID: <20001012190632.E3189@redhat.com>
References: <39E5E469.2020304@SANgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39E5E469.2020304@SANgate.com>; from gabriel@SANgate.com on Thu, Oct 12, 2000 at 07:18:49PM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BenHanokh Gabriel <gabriel@SANgate.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Oct 12, 2000 at 07:18:49PM +0300, BenHanokh Gabriel wrote:
> 
> i saw that the raw interface is using 1/2K blocks for io.
> i understand that raw_io needs to support disk accesses in sector 
> resolution, but why is it not possible to mix block sizes for the same 
> device

It is possible in principle, but I can't guarantee that every device
driver will work properly if you do this.

> is there any reason why we don't use mix-block-size ?

Because it would be a short-term hack --- the real solution to this
problem is to push kiobufs right down into the block device request
layer.  SGI have already got patches to do this, with support in the
scsi and ide drivers.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
