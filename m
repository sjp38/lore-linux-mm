Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7C6DB6B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 06:14:04 -0500 (EST)
Date: Thu, 10 Jan 2013 11:14:03 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [v2] fadvise: perform WILLNEED readahead asynchronously
Message-ID: <20130110111403.GA730@dcvr.yhbt.net>
References: <20121225022251.GA25992@dcvr.yhbt.net>
 <50EE8B6B.1050204@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50EE8B6B.1050204@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Dave Chinner <david@fromorbit.com>, Zheng Liu <gnehzuil.liu@gmail.com>

Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com> wrote:
> Hello,
> 
> Il 25/12/2012 03:22, Eric Wong ha scritto:
> > Any other (Free Software) applications that might benefit from
> > lower FADV_WILLNEED latency?
> 
> Not with fadvise but with madvise. Libreoffice / Openoffice.org have
> this comment:
> 
> // On Linux, madvise(..., MADV_WILLNEED) appears to have the undesirable
> // effect of not returning until the data has actually been paged in, so
> // that its net effect would typically be to slow down the process
> // (which could start processing at the beginning of the data while the
> // OS simultaneously pages in the rest); on other platforms, it remains
> // to be evaluated whether madvise or equivalent is available and
> // actually useful:
> 
> See:
> http://cgit.freedesktop.org/libreoffice/core/tree/sal/osl/unx/file.cxx#n1213
> 
> May the same approach be extended to madvise MADV_WILLNEED?

Definitely yes, it should be easy.  This project low-priority for me at
the moment, if you or anybody else wants to take a stab at it,
please do :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
