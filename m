Date: Wed, 6 Aug 2003 23:44:57 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test2-mm5
Message-Id: <20030806234457.5ca9e5af.akpm@osdl.org>
In-Reply-To: <20030807063311.GX32488@holomorphy.com>
References: <20030806223716.26af3255.akpm@osdl.org>
	<20030807063311.GX32488@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
>  Looks like this got backed out when vmlinux.lds.S moved:
> 

yes it did, thanks.

>  --- linux-old/arch/i386/kernel/vmlinux.lds.S	2003-08-06 23:23:53.000000000 -0700
>  +++ linux-new/arch/i386/kernel/vmlinux.lds.S	2003-08-04 15:02:26.000000000 -0700

Yes, that change is needed for building with the 4g/4g split.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
