Date: Fri, 8 Aug 2003 14:36:13 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test2-mm5
Message-ID: <20030808213613.GC32488@holomorphy.com>
References: <Pine.LNX.4.44.0308071905200.5090-100000@logos.cnet> <Pine.LNX.4.44.0308081749470.10734-300000@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0308081749470.10734-300000@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 08, 2003 at 05:51:07PM -0300, Marcelo Tosatti wrote:
> William, Andrew,
> Attached are the full boot messages before the crash plus lspci -vvv 
> output.
> PXELINUX 1.62 2001-04-24  Copyright (C) 1994-2001 H. Peter Anvin
> boot: 
> Booting from local disk...

What happens near or around the reported point of failure with
initcall_debug on?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
