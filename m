Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 642696B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 07:19:37 -0400 (EDT)
Message-ID: <5177BFE2.9020704@parallels.com>
Date: Wed, 24 Apr 2013 15:20:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
References: <1366705329-9426-1-git-send-email-glommer@openvz.org> <1366705329-9426-2-git-send-email-glommer@openvz.org> <20130423202446.GA2484@teo>
In-Reply-To: <20130423202446.GA2484@teo>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/24/2013 12:24 AM, Anton Vorontsov wrote:
> Setting the variable on every event seems a bit wasteful... does it make
> sense to set it in vmpressure_register_event()? We'll have to make it a
> counter, but the good thing is that we won't need any additional locks for
> the counter.
My bad, I was not looking at the code.

There are two variables here:

One of them is an event variable: kernel_event. It is set to true upon
registration when we are registering a kernel event. We use it to decide
whether we should call a function or signal eventfd for that event.

The other, is a vmpr event and should indeed, be set in all pressure
isntances. It tells us if we should only trigger kernel events (if
false), or userspace events as well (if true).

This is because, for instance, userspace events may not always be
triggered (for instance, due to flags mismatch)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
