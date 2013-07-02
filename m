Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id E3C486B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 14:38:53 -0400 (EDT)
Date: Tue, 2 Jul 2013 14:38:22 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130702143822.4af2ebe3@redhat.com>
In-Reply-To: <20130702172409.GA13695@teo>
References: <20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
	<20130628100027.31504abe@redhat.com>
	<20130628165722.GA12271@teo>
	<20130628170917.GA12610@teo>
	<20130628144507.37d28ed9@redhat.com>
	<20130628185547.GA14520@teo>
	<20130628154402.4035f2fa@redhat.com>
	<20130629005637.GA16068@teo>
	<20130702105911.2830181d@redhat.com>
	<20130702172409.GA13695@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Tue, 2 Jul 2013 10:24:09 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> > Honestly, what Andrew suggested is the best design for me: apps
> > are notified on all events but the event name is sent to the application.
> 
> I am fine with this approach (or any other, I'm really indifferent to the
> API itself -- read/netlink/notification per file/whatever for the
> payload),

That's a very good thing because we've managed to agree on something :)

I'm also indifferent to the API, as long as we have 100% of the policy
in user-space. To me this means we do absolutely no filtering in the
kernel, which in turn means user-space gets all the events. Of course,
we need the event name as a payload.

Do we agree this solves all use-cases we have discussed so far?

> except that you still have the similar problem:
> 
>   read() old    read() new
>   --------------------------
>        "low"           "low"
>        "low"           "foo" -- the app does not know what does this mean
>        "med"           "bar" -- ditto

It can just ignore it, have a special handling, log it, fail or whatever.
That's the good of having the policy in user-space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
