Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3C1F56B004D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 01:58:21 -0400 (EDT)
Date: Wed, 1 Apr 2009 22:59:06 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 4/4 alternative userspace] add ksm kernel shared memory
	driver
Message-ID: <20090402055906.GH1117@x200.localdomain>
References: <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws> <20090402054816.GG1117@x200.localdomain> <36ca99e90904012257j5f5e6e2co673ff2433d49b7b9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <36ca99e90904012257j5f5e6e2co673ff2433d49b7b9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bert Wesarg <bert.wesarg@googlemail.com>
Cc: Chris Wright <chrisw@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

* Bert Wesarg (bert.wesarg@googlemail.com) wrote:
> > Unregister a shareable memory region (not currently implemented):
                                          ^^^^^^^^^^^^^^^^^^^^^^^^^
> > madvise(void *addr, size_t len, MADV_UNSHAREABLE)
> I can't find a definition for MADV_UNSHAREABLE!

It's not there ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
