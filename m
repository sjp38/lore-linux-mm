Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5830B6B004D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 21:43:42 -0400 (EDT)
Date: Thu, 1 Nov 2012 21:43:36 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
Message-ID: <20121102014336.GA1727@redhat.com>
References: <20121025023738.GA27001@redhat.com>
 <alpine.LNX.2.00.1210242121410.1697@eggly.anvils>
 <20121101191052.GA5884@redhat.com>
 <alpine.LNX.2.00.1211011546090.19377@eggly.anvils>
 <20121101232030.GA25519@redhat.com>
 <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 01, 2012 at 04:48:41PM -0700, Hugh Dickins wrote:
 > On Thu, 1 Nov 2012, Dave Jones wrote:
 > > On Thu, Nov 01, 2012 at 04:03:40PM -0700, Hugh Dickins wrote:
 > >  > 
 > >  > Except... earlier in the thread you explained how you hacked
 > >  > #define VM_BUG_ON(cond) WARN_ON(cond)
 > >  > to get this to come out as a warning instead of a bug,
 > >  > and now it looks as if "a user" has here done the same.
 > >  > 
 > >  > Which is very much a user's right, of course; but does
 > >  > make me wonder whether that user might actually be davej ;)
 > > 
 > > indirectly. I made the same change in the Fedora kernel a while ago
 > > to test a hypothesis that we weren't getting any VM_BUG_ON reports.
 > 
 > Fedora turns on CONFIG_DEBUG_VM?

Yes.
 
 > All mm developers should thank you for the wider testing exposure;
 > but I'm not so sure that Fedora users should thank you for turning
 > it on - really it's for mm developers to wrap around !assertions or
 > more expensive checks (e.g. checking calls) in their development.

The last time I did some benchmarking the impact wasn't as ridiculous
as say lockdep, or spinlock debug. Maybe the benchmarks I was using
weren't pushing the VM very hard, but it seemed to me that the value
in getting info in potential problems early was higher than a small
performance increase.

 > Or did I read a few months ago that some change had been made to
 > such definitions, and VM_BUG_ON(contents) are evaluated even when
 > the config option is off?  I do hope I'm mistaken on that.

Pretty sure that isn't the case. I remember Andrew chastising people
a few times for putting checks in VM_BUG_ON's that needed to stay around 
even when the config option was off. Perhaps you were thinking of one
of those incidents ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
