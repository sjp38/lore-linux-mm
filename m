Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5FCF6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 14:41:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so1505189916pgi.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 11:41:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x13si41800708plm.213.2017.01.05.11.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 11:41:15 -0800 (PST)
Date: Thu, 5 Jan 2017 11:42:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 190191] New: kswapd0 spirals out of control
Message-Id: <20170105114233.b5c80f88f625815eaec70bc1@linux-foundation.org>
In-Reply-To: <bug-190191-27@https.bugzilla.kernel.org/>
References: <bug-190191-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, dh@kernel.usrbin.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 12 Dec 2016 19:38:23 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=190191
> 
>             Bug ID: 190191
>            Summary: kswapd0 spirals out of control
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.8.0+
>           Hardware: i386
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: dh@kernel.usrbin.org
>         Regression: No

I'd say "Regression: yes".

Additional details at the link.  There's no indication which commit(s)
broke it.

> Created attachment 247481
>   --> https://bugzilla.kernel.org/attachment.cgi?id=247481&action=edit
> config for 4.7
> 
> I'm currently running 4.7.10 with no problems, but when i tried to upgrade to
> 4.8.0 (and just now, 4.9.0) i encountered a problem that makes my system
> unusable.
> 
> When running certain jobs, kswapd0 will consume more and more cpu cycles until
> `top' lists it at 100% and everything else slows to a crawl and makes the
> system almost completely unresponsive.
> 
> The main time i notice this is when running big rsync jobs between my
> computers, which i do regularly (masochistic homebrew packaging system, don't
> ask).
> 
> `free' never indicates any swap usage while this is going on; the systems have
> 4GB and 8GB of memory respectively and neither is getting filled up.
> 
> I've never seen this problem before and i've been running self-compiled kernels
> early in the 2.x days.
> 
> `echo 1 > /proc/sys/vm/drop_caches' works to clear the logjam, but then it just
> happens again in short order.
> 
> I'm attaching my .config for 4.7 and 4.9, in case this has something to do with
> my configuration options.
> 
> Sorry this isn't very precise, but i'm not sure how to further debug this and
> don't have a strong enough understanding of the systems involved to know what
> to provide.  If i can try anything to help pinpoint the issue, please let me
> know!
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
