Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 2F8F36B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:07:05 -0400 (EDT)
Received: by dakp5 with SMTP id p5so9204459dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 13:07:04 -0700 (PDT)
Date: Mon, 14 May 2012 13:06:59 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interface
Message-ID: <20120514200659.GA15604@kroah.com>
References: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com

On Thu, May 10, 2012 at 12:06:21PM -0700, Dan Magenheimer wrote:
> RAMster does many zcache-like things.  In order to avoid major
> merge conflicts at 3.4, ramster used lzo1x directly for compression
> and retained a local copy of xvmalloc, while zcache moved to the
> new zsmalloc allocator and the crypto API.
> 
> This patch moves ramster forward to use zsmalloc and crypto.
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

I finally enabled building this one (didn't realize it required ZCACHE
to be disabled, I can only build one or the other), and I noticed after
this patch the following warnings in my build:

drivers/staging/ramster/zcache-main.c:950:13: warning: a??zcache_do_remotify_opsa?? defined but not used [-Wunused-function]
drivers/staging/ramster/zcache-main.c:1039:13: warning: a??ramster_remotify_inita?? defined but not used [-Wunused-function]
drivers/staging/ramster/zcache-main.c: In function a??zcache_puta??:
drivers/staging/ramster/zcache-main.c:1594:4: warning: a??pagea?? may be used uninitialized in this function [-Wuninitialized]
drivers/staging/ramster/zcache-main.c:1536:8: note: a??pagea?? was declared here

Care to please fix them up?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
