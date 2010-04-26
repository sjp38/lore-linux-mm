Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 18C386B01F1
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 18:18:46 -0400 (EDT)
Message-ID: <4BD61147.40709@tauceti.net>
Date: Tue, 27 Apr 2010 00:18:47 +0200
From: Robert Wimmer <kernel@tauceti.net>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net> <20100419131718.GB16918@redhat.com> <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net> <20100421094249.GC30855@redhat.com> <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net> <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net> <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net> <20100425204916.GA12686@redhat.com> <1272284154.4252.34.camel@localhost.localdomain> <4BD5F6C5.8080605@tauceti.net> <1272315854.8984.125.camel@localhost.localdomain>
In-Reply-To: <1272315854.8984.125.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> Sure. In addition to what you did above, please do
>
> mount -t debugfs none /sys/kernel/debug
>
> and then cat the contents of the pseudofile at
>
> /sys/kernel/debug/tracing/stack_trace
>
> Please do this more or less immediately after you've finished mounting
> the NFSv4 client.
>   

I've uploaded the stack trace. It was generated
directly after mounting. Here are the stacks:

After mounting:
https://bugzilla.kernel.org/attachment.cgi?id=26153
After the soft lockup:
https://bugzilla.kernel.org/attachment.cgi?id=26154
The dmesg output of the soft lockup:
https://bugzilla.kernel.org/attachment.cgi?id=26155

> Does your server have the 'crossmnt' or 'nohide' flags set, or does it
> use the 'refer' export option anywhere? If so, then we might have to
> test further, since those may trigger the NFSv4 submount feature.
>   
The server has the following settings:
rw,nohide,insecure,async,no_subtree_check,no_root_squash

Thanks!
Robert


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
