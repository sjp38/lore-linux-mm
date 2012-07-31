Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp102.postini.com [74.125.245.222])
	by kanga.kvack.org (Postfix) with SMTP id ABE196B008A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:03 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so13551549pbb.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 09:19:20 -0700 (PDT)
Date: Tue, 31 Jul 2012 09:19:16 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120731161916.GA4941@kroah.com>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
 <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
 <20120731155843.GP4789@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120731155843.GP4789@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Tue, Jul 31, 2012 at 11:58:43AM -0400, Konrad Rzeszutek Wilk wrote:
> So in my head I feel that it is Ok to:
> 1) address the concerns that zcache has before it is unstaged
> 2) rip out the two-engine system with a one-engine system
>    (and see how well it behaves)
> 3) sysfs->debugfs as needed
> 4) other things as needed
> 
> I think we are getting hung-up what Greg said about adding features
> and the two-engine->one engine could be understood as that.
> While I think that is part of a staging effort to clean up the
> existing issues. Lets see what Greg thinks.

Greg has no idea, except I want to see the needed fixups happen before
new features get added.  Add the new features _after_ it is out of
staging.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
