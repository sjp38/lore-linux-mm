Date: Mon, 9 Feb 2004 11:54:53 -0500 (EST)
From: James Morris <jmorris@redhat.com>
Subject: Re: 2.6.3-rc1-mm1
In-Reply-To: <20040209014035.251b26d1.akpm@osdl.org>
Message-ID: <Xine.LNX.4.44.0402091153210.2328-100000@thoron.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Feb 2004, Andrew Morton wrote:

> +highmem-equals-user-friendliness.patch
> 
>  Enhance and document the `highmem=' ia32 kernel boot option.  This also
>  gives us highmem emulation on <= 896M boxes.

This seems to be breaking initrd when highmem is enabled:

  initrd extends beyond end of memory (0x37feffc9 > 0x30400000)
  disabling initrd


- James
-- 
James Morris
<jmorris@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
