Date: Mon, 14 May 2001 10:43:05 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kernel position
Message-ID: <20010514104305.N7594@redhat.com>
References: <20010514092219.55514.qmail@web13202.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010514092219.55514.qmail@web13202.mail.yahoo.com>; from any_and@yahoo.com on Mon, May 14, 2001 at 02:22:19AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Any Anderson <any_and@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, May 14, 2001 at 02:22:19AM -0700, Any Anderson wrote:

> I wann know where in the physical memory is kernel
> loaded by the loader (such as lilo)

Look at the Technical_Guide.ps documentation file in the lilo
distribution: it contains a lot of detail on exactly what gets loaded
where during boot.

> and does this
> position has any significance in mm system. 

Not really, no.  The only impact is that the architecture-specific
parts of the MM's initialisation need to be aware of a few details of
the boot process.  In particular, they need to know where any initrd
ramdisk has been loaded so that they don't try to reuse that memory
until the initial ramdisk has been freed.  Apart from that, the MM
system really knows nothing about booting.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
