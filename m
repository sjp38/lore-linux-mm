Message-ID: <3C05954B.9AC5B6BA@zip.com.au>
Date: Wed, 28 Nov 2001 17:54:19 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: Status of sendfile() + HIGHMEM
References: <3C0577FF.3040209@zytor.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"H. Peter Anvin" wrote:
> 
> zeus.kernel.org is currently running with HIGHMEM turned off, since it
> crashed due to an unfortunate interaction between sendfile() and HIGHMEM
> -- this was using 2.4.10-ac4 or thereabouts.
> 

What sort of NIC is it using?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
