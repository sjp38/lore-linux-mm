Date: Wed, 13 Aug 2003 14:50:21 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [patch] Add support for more than 256 zones
Message-ID: <955130000.1060811421@flay>
In-Reply-To: <20030813135538.19c96c67.akpm@osdl.org>
References: <3F3A9E46.6010803@sgi.com> <20030813135538.19c96c67.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Jay Lan <jlan@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Yes, this is good - it gives us five more page flags on 32-bit machines. 
> Assuming that no 32 bit machiens will ever need more than three zones(?)

There has been talk already of a ZONE_DMA32 or whatever (first 4GB).
That'd be useful for quite a few things, so might be nice to leave
space for at least four zones ...

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
