Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA23228
	for <linux-mm@kvack.org>; Wed, 18 Sep 2002 09:29:41 -0700 (PDT)
Message-ID: <3D88A9F5.F39ECD20@digeo.com>
Date: Wed, 18 Sep 2002 09:29:41 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] recognize MAP_LOCKED in mmap() call
References: <3D815C8C.4050000@us.ibm.com> <1031922352.9056.14.camel@irongate.swansea.linux.org.uk> <20020913213042.GD3530@holomorphy.com> <200209181207.26655.frankeh@watson.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@watson.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hubertus Franke wrote:
> 
> Andrew, at the current time an mmap() ignores a MAP_LOCKED passed to it.
> The only way we can get VM_LOCKED associated with the newly created VMA
> is to have previously called mlockall() on the process which sets the
> mm->def_flags != VM_LOCKED or subsequently call mlock() on the
> newly created VMA.
> 
> The attached patch checks for MAP_LOCKED being passed and if so checks
> the capabilities of the process. Limit checks were already in place.

Looks sane, thanks.

It appears that MAP_LOCKED is a Linux-special, so presumably it
_used_ to work.  I wonder when it broke?

You patch applies to 2.4 as well; it would be useful to give that
a sanity test and send a copy to Marcelo.

(SuS really only anticipates that mmap needs to look at prior mlocks
in force against the address range.  It also says

     Process memory locking does apply to shared memory regions,

and we don't do that either.  I think we should; can't see why SuS
requires this.)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
