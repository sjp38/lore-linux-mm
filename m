Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 6F8556B0119
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 19:34:13 -0400 (EDT)
Received: by dadv6 with SMTP id v6so13260285dad.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:34:12 -0700 (PDT)
Date: Mon, 19 Mar 2012 16:34:09 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: add user-definable alloc/free funcs
Message-ID: <20120319233409.GA16124@kroah.com>
References: <1331931888-14175-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120316213227.GB24556@kroah.com>
 <4F678100.1000707@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F678100.1000707@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Mon, Mar 19, 2012 at 01:54:56PM -0500, Seth Jennings wrote:
> > I'm sorry, I know this isn't fair for your specific patch, but we have
> > to stop this sometime, and as this patch adds code isn't even used by
> > anyone, its a good of a time as any.
> 
> So, this the my first "promotion from staging" rodeo.  I would love to
> see this code mainlined ASAP.  How would I/we go about doing that?

What subsystem should this code live in?  The -mm code, I'm guessing,
right?  If so, submit it to the linux-mm mailing list for inclusion, you
can point them at what is in drivers/staging right now, or probably it's
easier if you just make a new patch that adds the code that is in
drivers/staging/ to the correct location in the kernel.  That way it's
easier to review and change.  When it finally gets accepted, we can then
delete the drivers/staging code.

hope this helps,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
