Date: Tue, 29 Apr 2003 10:03:58 +0200
From: Jan Hudec <bulb@ucw.cz>
Subject: Re: questions on swapping
Message-ID: <20030429080358.GB668@vagabond>
References: <OF82D3C19C.A5743FFE-ON65256D16.00349A8A@celetron.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF82D3C19C.A5743FFE-ON65256D16.00349A8A@celetron.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heerappa Hunje <hunjeh@celetron.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 28, 2003 at 03:07:08PM +0530, Heerappa Hunje wrote:
> Let me know how much of memory a system adminstrator can configure for
> buffering mechanism out 128MB/256MB  or it will be choosen by the Linux
> itself.

Buffers are rather transient stuff during IO operations. Kernel will
allocate memory for them as they are needed.

All memory, that is not used by kernel or applications is used for
caching files (page cache). No need to configure that either.

-------------------------------------------------------------------------------
						 Jan 'Bulb' Hudec <bulb@ucw.cz>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
