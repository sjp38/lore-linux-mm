Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id D99306B006C
	for <linux-mm@kvack.org>; Sat, 29 Sep 2012 04:41:59 -0400 (EDT)
Message-ID: <1348908118.1553.23.camel@x61.thuisdomein>
Subject: Re: [PATCH -v2] mm: frontswap: fix a wrong if condition in
 frontswap_shrink
From: Paul Bolle <pebolle@tiscali.nl>
Date: Sat, 29 Sep 2012 10:41:58 +0200
In-Reply-To: <506662DD.4030309@oracle.com>
References: <505C27FE.5080205@oracle.com>
	  <1348745730.1512.19.camel@x61.thuisdomein> <50651CF5.5030903@oracle.com>
	 <1348844071.1553.14.camel@x61.thuisdomein> <506662DD.4030309@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhenzhong.duan@oracle.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, levinsasha928@gmail.com, Feng Jin <joe.jin@oracle.com>, dan.carpenter@oracle.com

On Sat, 2012-09-29 at 10:54 +0800, Zhenzhong Duan wrote:
> On 2012-09-28 22:54, Paul Bolle wrote:
> > Not even before applying your patch? Anyhow, after applying your patch
> > the warnings gone here too.
> I tested both cases, no warning, also didn't see -Wmaybe-uninitialized 
> when make.
> My env is el5. gcc version 4.1.2 20080704 (Red Hat 4.1.2-52)
> Maybe your gcc built in/implicit spec use that option?

I simply use what (was and) is shipped by Fedora 17:
    $ sudo grep -w gcc /var/log/yum.log 
    Sep 12 11:45:54 Installed: gcc-4.7.0-5.fc17.x86_64
    Sep 27 13:54:24 Updated: gcc-4.7.2-2.fc17.x86_64

So I did my patch with a version of GCC's release 4.7.0, and tested your
patch with a version of GCC's 4.7.2 release.

I don't think I tweaked any settings. Unless there are strong reasons to
do otherwise, I try to use the tools shipped by Fedora in their default
settings. (I'm not even sure there's a way to set one's GCC settings
locally.)


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
