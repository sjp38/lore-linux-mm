Date: Sat, 4 Oct 2003 15:29:06 -0400
From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 2.6.0-test6-mm3
Message-ID: <20031004192906.GB30371@gtf.org>
References: <20031004021255.3fefbacb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031004021255.3fefbacb.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 04, 2003 at 02:12:55AM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test6/2.6.0-test6-mm3/
> 
> . Added the Intel MSI interrupt patch.  This is mainly to get it under
>   test and under review and to provide the Intel developers with a codebase
>   against which to continue working.  Probably nobody has the hardware yet.

MSI cards have been out there for a while, now.
I dunno about the FSB pieces, though...

I could have sworn Intel ICH5 (now released) supports MSI...

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
