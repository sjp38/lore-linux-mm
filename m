Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 856836B0071
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 04:35:40 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id z2so142463wey.18
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 01:35:38 -0800 (PST)
Message-ID: <50EE8B6B.1050204@gmail.com>
Date: Thu, 10 Jan 2013 10:35:39 +0100
From: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
MIME-Version: 1.0
Subject: Re: [v2] fadvise: perform WILLNEED readahead asynchronously
References: <20121225022251.GA25992@dcvr.yhbt.net>
In-Reply-To: <20121225022251.GA25992@dcvr.yhbt.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Dave Chinner <david@fromorbit.com>, Zheng Liu <gnehzuil.liu@gmail.com>

Hello,

Il 25/12/2012 03:22, Eric Wong ha scritto:
 > Any other (Free Software) applications that might benefit from
 > lower FADV_WILLNEED latency?

Not with fadvise but with madvise. Libreoffice / Openoffice.org have 
this comment:

// On Linux, madvise(..., MADV_WILLNEED) appears to have the undesirable
// effect of not returning until the data has actually been paged in, so
// that its net effect would typically be to slow down the process
// (which could start processing at the beginning of the data while the
// OS simultaneously pages in the rest); on other platforms, it remains
// to be evaluated whether madvise or equivalent is available and
// actually useful:

See:
http://cgit.freedesktop.org/libreoffice/core/tree/sal/osl/unx/file.cxx#n1213

May the same approach be extended to madvise MADV_WILLNEED?

thanks,
riccardo magliocchetti

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
