Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B70006B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:14:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r6so8773624pfj.14
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 23:14:10 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 6si204583plc.512.2017.10.19.23.14.08
        for <linux-mm@kvack.org>;
        Thu, 19 Oct 2017 23:14:09 -0700 (PDT)
Date: Fri, 20 Oct 2017 15:14:06 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Message-ID: <20171020061406.GF3310@X58A-UD3R>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
 <1508455438.4542.4.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508455438.4542.4.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

On Thu, Oct 19, 2017 at 11:24:00PM +0000, Bart Van Assche wrote:
> Are there any completion objects for which the cross-release checking is
> useful? Are there any wait_for_completion() callers that hold a mutex or
> other locking object?

Check /proc/lockdep, then you can find all dependencies wrt cross-lock.
I named a lock class of wait_for_completion(), a sting starting with
"(complete)".

For example, in my machine:

console_lock -> (complete)&req.done
cpu_hotplug_lock.rw_sem -> (complete)&st->done_up
cpuhp_state_mutex -> (complete)&st->done_up

and so on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
