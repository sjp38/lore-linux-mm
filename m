Date: Wed, 6 Jun 2001 09:23:58 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: temp. mem mappings
Message-ID: <20010606092358.R26756@redhat.com>
References: <3B581215@MailAndNews.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B581215@MailAndNews.com>; from cohutta@MailAndNews.com on Tue, Jun 05, 2001 at 04:42:52PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cohutta <cohutta@MailAndNews.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 05, 2001 at 04:42:52PM -0400, cohutta wrote:

>   Normal memory is identity-mapped very early in boot anyway (except for
>   highmem on large Intel boxes, that is, and kmap() works for that.)
> 
> I don't really want to play with the page tables if i can help it.
> I didn't use ioremap() because it's real system memory, not IO bus
> memory.
> 
> How much normal memory is identity-mapped at boot on x86?
> Is it more than 8 MB?

> I'm trying to read some ACPI tables, like the FACP.
> On my system, this is at physical address 0x3fffd7d7 (e.g.).

It depends at what time during boot.  Some ACPI memory is reusable
once the system boots: the kernel parses the table then frees up the
memory which the BIOS initialised.

VERY early in boot, while the VM is still getting itself set up, there
is only a minimal mapping set up by the boot loader code.  However,
once the VM is initialised far enough to let you play with page
tables, all memory will be identity-mapped up to just below the 1GB
watermark.

> kmap() ends up calling set_pte(), which is close to what i am
> already doing.  i'm having a problem on the unmap side when i
> am done with the temporary mapping.

kunmap().  :-)  But kmap only works on CONFIG_HIGHMEM kernel builds.
On kernels built without high memory support, kmap will not allow you
to access memory beyond the normal physical memory boundary.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
