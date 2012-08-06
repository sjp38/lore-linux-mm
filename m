Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 8CB676B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 20:36:57 -0400 (EDT)
Date: Mon, 6 Aug 2012 09:38:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120806003816.GA11375@bbox>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
 <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
 <20120731155843.GP4789@phenom.dumpdata.com>
 <20120731161916.GA4941@kroah.com>
 <20120731175142.GE29533@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120731175142.GE29533@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

Hi Konrad,

On Tue, Jul 31, 2012 at 01:51:42PM -0400, Konrad Rzeszutek Wilk wrote:
> On Tue, Jul 31, 2012 at 09:19:16AM -0700, Greg Kroah-Hartman wrote:
> > On Tue, Jul 31, 2012 at 11:58:43AM -0400, Konrad Rzeszutek Wilk wrote:
> > > So in my head I feel that it is Ok to:
> > > 1) address the concerns that zcache has before it is unstaged
> > > 2) rip out the two-engine system with a one-engine system
> > >    (and see how well it behaves)
> > > 3) sysfs->debugfs as needed
> > > 4) other things as needed
> > > 
> > > I think we are getting hung-up what Greg said about adding features
> > > and the two-engine->one engine could be understood as that.
> > > While I think that is part of a staging effort to clean up the
> > > existing issues. Lets see what Greg thinks.
> > 
> > Greg has no idea, except I want to see the needed fixups happen before
> > new features get added.  Add the new features _after_ it is out of
> > staging.
> 
> I think we (that is me, Seth, Minchan, Dan) need to talk to have a good
> understanding of what each of us thinks are fixups.
> 
> Would Monday Aug 6th at 1pm EST on irc.freenode.net channel #zcache work
> for people?

1pm EST is 2am KST(Korea Standard Time) so it's not good for me. :)
I know it's hard to adjust my time for yours so let you talk without
me. Instead, I will write it down my requirement. It's very simple and
trivial.

1) Please don't add any new feature like replace zsmalloc with zbud.
   It's totally untested so it needs more time for stable POV bug,
   or performance/fragementation.

2) Factor out common code between zcache and ramster. It should be just
   clean up code and should not change current behavior.

3) Add lots of comment to public functions

4) make function/varabiel names more clearly.

They are necessary for promotion and after promotion,
let's talk about new great features.


> 
> > 
> > greg k-h
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
