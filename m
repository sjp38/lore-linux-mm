Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D4D986B0044
	for <linux-mm@kvack.org>; Sat,  8 Dec 2012 13:47:20 -0500 (EST)
From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [memcg:since-3.6 493/499] include/trace/events/filemap.h:14:1: sparse: incompatible types for operation (<)
References: <50b7f3c5.kjvAZJjuJNxsqjDZ%fengguang.wu@intel.com>
	<87ehj81pxx.fsf@free.fr>
	<1354932053.17101.113.camel@gandalf.local.home>
Date: Sat, 08 Dec 2012 19:47:03 +0100
In-Reply-To: <1354932053.17101.113.camel@gandalf.local.home> (Steven Rostedt's
	message of "Fri, 07 Dec 2012 21:00:53 -0500")
Message-ID: <877gosz8ig.fsf@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kbuild test robot <fengguang.wu@intel.com>

Steven Rostedt <rostedt@goodmis.org> writes:

> Sorry for the late reply, It's end of year and I'm getting a lot of
> pressure at work to get things done.
Don't worry, no hurry in here.

> Hmm, this is mostly automated via the macros. Not sure how we can
> differentiate a pointer from other fields. Would this be fixed if we
> did:
>
> #define is_signed_type(type) (((type)(-1) < (type)0)

Yes indeed, this quiesces the sparse warning, and keeps the original purpose
AFAIK. And I don't think C standard provides a way to typecheck for any kind of
pointer, so this looks the right fix to me .

Will you submit the patch or do you want me to send it ?

Cheers.

-- 
Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
