Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4A0C06B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 21:22:04 -0400 (EDT)
Date: Wed, 1 Apr 2009 18:22:15 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090402012215.GE1117@x200.localdomain>
References: <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49D24A02.6070000@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

* Anthony Liguori (anthony@codemonkey.ws) wrote:
> The ioctl() interface is quite bad for what you're doing.  You're  
> telling the kernel extra information about a VA range in userspace.   
> That's what madvise is for.  You're tweaking simple read/write values of  
> kernel infrastructure.  That's what sysfs is for.

I agree re: sysfs (brought it up myself before).  As far as madvise vs.
ioctl, the one thing that comes from the ioctl is fops->release to
automagically unregister memory on exit.  This needs to be handled
anyway if some -p pid is added to add a process after it's running,
so less weight there.

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
