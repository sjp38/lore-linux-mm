Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 19E9A6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 17:55:06 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id jh10so752006pab.38
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 14:55:05 -0700 (PDT)
Date: Tue, 23 Apr 2013 17:01:49 -0400
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
Message-ID: <20130423210149.GA9019@teo>
References: <1366705329-9426-1-git-send-email-glommer@openvz.org>
 <1366705329-9426-2-git-send-email-glommer@openvz.org>
 <20130423202446.GA2484@teo>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130423202446.GA2484@teo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Apr 23, 2013 at 04:24:46PM -0400, Anton Vorontsov wrote:
[...]
> >  /**
> > + * vmpressure_register_kernel_event() - Register kernel-side notification
> 
> Why don't we need the unregister function? I see that the memcg portion
> deals with dangling memcgs, but do they dangle forver?

Oh, I got it. vmpressure_unregister_event() will unregister all the events
anyway. Cool.

Thanks!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
