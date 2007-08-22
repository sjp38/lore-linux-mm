Date: Wed, 22 Aug 2007 21:55:50 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 6/6] x86: acpi-use-cpu_physical_id
Message-ID: <20070822195550.GE8058@bingen.suse.de>
References: <20070822172101.138513000@sgi.com> <20070822172124.217932000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070822172124.217932000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 10:21:07AM -0700, travis@sgi.com wrote:
> This is from an earlier message from Christoph Lameter:
> 
>     processor_core.c currently tries to determine the apicid by special casing
>     for IA64 and x86. The desired information is readily available via
> 
> 	    cpu_physical_id()
> 
>     on IA64, i386 and x86_64.

Have you tried this with a !CONFIG_SMP build? The drivers/dma code was doing
the same and running into problems because it wasn't defined there.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
