Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 7D95A6B0033
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 13:56:12 -0400 (EDT)
Received: by mail-qe0-f54.google.com with SMTP id ne12so2479031qeb.13
        for <linux-mm@kvack.org>; Mon, 08 Jul 2013 10:56:11 -0700 (PDT)
Date: Mon, 8 Jul 2013 10:56:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130708175607.GB18600@mtj.dyndns.org>
References: <20130708100046.14417.12932.stgit@zurg>
 <20130708170047.GA18600@mtj.dyndns.org>
 <20130708175201.GB9094@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130708175201.GB9094@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

Hello, Vivek.

On Mon, Jul 08, 2013 at 01:52:01PM -0400, Vivek Goyal wrote:
> > Again, a problem to be fixed in the stack rather than patching up from
> > up above.  The right thing to do is to propagate pressure through bdi
> > properly and let whatever is backing the bdi generate appropriate
> > amount of pressure, be that disk or network.
> 
> Ok, so use network controller for controlling IO rate on NFS? I had
> tried it once and it did not work. I think it had problems related
> to losing the context info as IO propagated through the stack. So
> we will have to fix that too.

But that's a similar problem we have with blkcg anyway - losing the
dirtier information by the time writeback comes down through bdi.  It
might not be exactly the same and might need some impedance matching
on the network side but I don't see any fundamental differences.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
