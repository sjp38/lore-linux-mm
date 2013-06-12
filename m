Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 3C13E6B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 00:48:29 -0400 (EDT)
Message-ID: <1371012507.2069.4.camel@joe-AO722>
Subject: Re: [checkpatch] - Confusion
From: Joe Perches <joe@perches.com>
Date: Tue, 11 Jun 2013 21:48:27 -0700
In-Reply-To: <1371010505.2069.3.camel@joe-AO722>
References: <1370843475.58124.YahooMailNeo@web160106.mail.bf1.yahoo.com>
	 <CAK7N6vrQFK=9OQi7dDUgGWWNQk71x3BeqPA9x3Pq66baA61PrQ@mail.gmail.com>
	 <1370890140.99216.YahooMailNeo@web160102.mail.bf1.yahoo.com>
	 <8a2ec29d-e6d8-44ed-a70d-2273848706ce@VA3EHSMHS029.ehs.local>
	 <1371010505.2069.3.camel@joe-AO722>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>
Cc: PINTU KUMAR <pintu_agarwal@yahoo.com>, Andy Whitcroft <apw@canonical.com>, anish singh <anish198519851985@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2013-06-11 at 21:15 -0700, Joe Perches wrote:

> > 	typedef struct ctl_table ctl_table; (include/linux/sysctl.h)
> > is not correctly picked up by checkpatch.
> 
> checkpatch isn't a c compiler.
> It assumes any <foo>_t is a typedef.
> 
> > So, I assume this actually is a false positive.
> 
> Yup.

Another option is to use "struct ctl_table" instead of bare ctl_table.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
