Subject: Re: [kvm-devel] [PATCH][RFC] pte notifiers -- support for external
	page tables
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <11890207643068-git-send-email-avi@qumranet.com>
References: <11890207643068-git-send-email-avi@qumranet.com>
Content-Type: text/plain
Date: Thu, 06 Sep 2007 05:56:23 +1000
Message-Id: <1189022183.10802.184.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-05 at 22:32 +0300, Avi Kivity wrote:
> [resend due to bad alias expansion resulting in some recipients
>  being bogus]
> 
> Some hardware and software systems maintain page tables outside the normal
> Linux page tables, which reference userspace memory.  This includes
> Infiniband, other RDMA-capable devices, and kvm (with a pending patch).

And lguest.  I can't tell until I've actually implemented it, but I
think it will seriously reduce the need for page pinning which is why
only root can currently launch guests.

My concern is locking: this is called with the page lock held, and I
guess we have to bump the guest out if it's currently running.

(Oh, and this means lguest needs to do a reverse mapping somehow, but
I'll come up with something).

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
