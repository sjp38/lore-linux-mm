Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7B11C6B004D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 01:56:50 -0400 (EDT)
Received: by fxm22 with SMTP id 22so452025fxm.38
        for <linux-mm@kvack.org>; Wed, 01 Apr 2009 22:57:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090402054816.GG1117@x200.localdomain>
References: <20090331142533.GR9137@random.random>
	 <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws>
	 <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws>
	 <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws>
	 <20090402012215.GE1117@x200.localdomain>
	 <49D424AF.3090806@codemonkey.ws>
	 <20090402054816.GG1117@x200.localdomain>
Date: Thu, 2 Apr 2009 07:57:42 +0200
Message-ID: <36ca99e90904012257j5f5e6e2co673ff2433d49b7b9@mail.gmail.com>
Subject: Re: [PATCH 4/4 alternative userspace] add ksm kernel shared memory
	driver
From: Bert Wesarg <bert.wesarg@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 2, 2009 at 07:48, Chris Wright <chrisw@redhat.com> wrote:
> Ksm api (for users to register region):
>
> Register a memory region as shareable:
>
> madvise(void *addr, size_t len, MADV_SHAREABLE)
>
> Unregister a shareable memory region (not currently implemented):
>
> madvise(void *addr, size_t len, MADV_UNSHAREABLE)
I can't find a definition for MADV_UNSHAREABLE!

Bert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
