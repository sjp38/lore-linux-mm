Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 61EE28D0020
	for <linux-mm@kvack.org>; Fri, 11 May 2012 14:00:39 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4990042pbb.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 11:00:38 -0700 (PDT)
Date: Fri, 11 May 2012 11:00:33 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interface
Message-ID: <20120511180033.GB7920@kroah.com>
References: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
 <20120510192836.GA17750@jak-linux.org>
 <1ff67ec4-7dd0-49c8-9be2-e927f58e6472@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ff67ec4-7dd0-49c8-9be2-e927f58e6472@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Julian Andres Klode <jak@jak-linux.org>, devel@driverdev.osuosl.org, sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org

On Fri, May 11, 2012 at 09:23:12AM -0700, Dan Magenheimer wrote:
> > From: Julian Andres Klode [mailto:jak@jak-linux.org]
> > Sent: Thursday, May 10, 2012 1:29 PM
> > To: Dan Magenheimer
> > Cc: devel@driverdev.osuosl.org; linux-kernel@vger.kernel.org; gregkh@linuxfoundation.org; linux-
> > mm@kvack.org; ngupta@vflare.org; Konrad Wilk; sjenning@linux.vnet.ibm.com
> > Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interface
> > 
> > On Thu, May 10, 2012 at 12:06:21PM -0700, Dan Magenheimer wrote:
> > > RAMster does many zcache-like things.  In order to avoid major
> > > merge conflicts at 3.4, ramster used lzo1x directly for compression
> > > and retained a local copy of xvmalloc, while zcache moved to the
> > > new zsmalloc allocator and the crypto API.
> > >
> > > This patch moves ramster forward to use zsmalloc and crypto.
> > >
> > > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com
> > 
> > Nothing important, but the right ">" is missing here.
> 
> Oops!  Cut-and-paste error!  Thanks for noticing Julian!
> 
> Greg, do you need me to resubmit with the missing '>'?

No need, I'll fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
