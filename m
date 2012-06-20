Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7ACD66B005A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 13:04:00 -0400 (EDT)
Date: Wed, 20 Jun 2012 12:56:10 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: help converting zcache from sysfs to debugfs?
Message-ID: <20120620165610.GA2991@phenom.dumpdata.com>
References: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
 <4FE1DFDC.1010105@linux.vnet.ibm.com>
 <83884ff2-1a06-4d9c-a7eb-c53ab0cbb6b1@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <83884ff2-1a06-4d9c-a7eb-c53ab0cbb6b1@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sasha Levin <levinsasha928@gmail.com>

On Wed, Jun 20, 2012 at 08:30:35AM -0700, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: Re: help converting zcache from sysfs to debugfs?
> > 
> > Something like this (untested):
> 
> Nice!  I also need a set for atomic_long_t.
> 
> But forgive me if I nearly have a heart attack as I
> contemplate another chicken-and-egg scenario trying
> to get debugfs-support-for-atomics upstream before
> zcache code that depends on it.
> 
> Maybe I'm a leetle bit over-sensitized to dependencies...
> or maybe not enough ;-)

I wouldn't that much. Especially as Greg KH is the maintainer
of debugfs.
> 
> Anyway, I will probably use the ugly code and add a
> comment that says the code can be made cleaner when
> debugfs supports atomics.
> 
> Thanks!
> Dan
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
