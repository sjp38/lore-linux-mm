Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m410YCkA004837
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 20:34:12 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m410YBrv182604
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 18:34:11 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m410YBxM014395
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 18:34:11 -0600
Subject: Re: Re: Warning on memory offline (and possible in usual
	migration?)
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <28073963.1209598183931.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com>
	 <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	 <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	 <20080422045205.GH21993@wotan.suse.de>
	 <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080422094352.GB23770@wotan.suse.de>
	 <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
	 <20080423004804.GA14134@wotan.suse.de>
	 <20080429162016.961aa59d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080430065611.GH27652@wotan.suse.de>
	 <20080430001249.c07ff5c8.akpm@linux-foundation.org>
	 <20080430072620.GI27652@wotan.suse.de>
	 <28073963.1209598183931.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 30 Apr 2008 17:34:18 -0700
Message-Id: <1209602058.27240.4.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-01 at 08:29 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
> >
> >One issue that I am still not clear on is (in particular for memory 
> >offline) is how exactly to determine if a page is under read I/O. I 
> >initially thought simply checking for PageUptodate would do the trick.
> >
> All troublesome case I found was "write". In my understanding,
> at generic bufferted file write, xxx_write_begin() -> write -> xxx_write_end()
>  sequence is used. xxx_write_begin locks a page and xxx_write_end unlock it. 
> (and xxx_write_end() set a page to be Uptodate in usual case.)
> So,it seems we can depend on that a page is locked or not.

You can wait for PG_writeback to be cleared to wait for IO to finish.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
