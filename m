Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A4F0C6B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 15:28:41 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so1641272wgb.26
        for <linux-mm@kvack.org>; Thu, 10 May 2012 12:28:39 -0700 (PDT)
Date: Thu, 10 May 2012 21:28:36 +0200
From: Julian Andres Klode <jak@jak-linux.org>
Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interface
Message-ID: <20120510192836.GA17750@jak-linux.org>
References: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com

On Thu, May 10, 2012 at 12:06:21PM -0700, Dan Magenheimer wrote:
> RAMster does many zcache-like things.  In order to avoid major
> merge conflicts at 3.4, ramster used lzo1x directly for compression
> and retained a local copy of xvmalloc, while zcache moved to the
> new zsmalloc allocator and the crypto API.
> 
> This patch moves ramster forward to use zsmalloc and crypto.
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com

Nothing important, but the right ">" is missing here.

-- 
Julian Andres Klode  - Debian Developer, Ubuntu Member

See http://wiki.debian.org/JulianAndresKlode and http://jak-linux.org/.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
