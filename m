Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5F1CC6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 20:31:16 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 6so215255yxn.26
        for <linux-mm@kvack.org>; Wed, 01 Apr 2009 17:31:44 -0700 (PDT)
Message-ID: <49D4076D.4010500@codemonkey.ws>
Date: Wed, 01 Apr 2009 19:31:41 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238457560-7613-5-git-send-email-ieidus@redhat.com> <49D17C04.9070307@codemonkey.ws> <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <49D3F088.50600@redhat.com>
In-Reply-To: <49D3F088.50600@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> Anthony, the biggest problem about madvice() is that it is a real 
> system call api, i wouldnt want in that stage of ksm commit into api 
> changes of linux...
>
> The ioctl itself is restricting, madvice is much more...,
>
> Can we draft this issue to after ksm is merged, and after all the big 
> new fetures that we want to add to ksm will be merge....
> (then the api would be much more stable, and we will be able to ask 
> ppl in the list about changing of api, but for new driver that it yet 
> to be merged, it is kind of overkill to add api to linux)
>
> What do you think?

You can't change ABIs after something is merged or you break userspace.  
So you need to figure out the right ABI first.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
