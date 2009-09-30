Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 124F46B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 14:11:52 -0400 (EDT)
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>
	<20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr>
	<87iqf0o5sf.fsf@caffeine.danplanet.com> <4AC38477.4070007@free.fr>
	<87eipoo0po.fsf@caffeine.danplanet.com> <4AC39CE5.9080908@free.fr>
From: Dan Smith <danms@us.ibm.com>
Date: Wed, 30 Sep 2009 11:28:36 -0700
In-Reply-To: <4AC39CE5.9080908@free.fr> (Daniel Lezcano's message of "Wed\, 30 Sep 2009 20\:01\:09 +0200")
Message-ID: <877hvgnv6z.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, mingo@elte.hu, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

DL> Yep, I agree. But you didn't answer the question, what are the
DL> network resources you plan to checkpoint / restart ?  eg. you let
DL> the container to setup your network, will you restore netdev
DL> statistics ? the mac address ? ipv4 ? ipv6 ?

Yes, Yes, Yes, and Yes.  I'm making the assumption that the common
case will be with a veth device in the container and that all of the
aforementioned attributes should be copied over.  In the future case
where we could potentially have a real device in the container, it
probably doesn't make sense to copy the mac address.

DL> Is it possible to do a detailed list of network resources you plan
DL> to CR with the different items you will address from userspace and
DL> kernel space ?

I'm sure it's possible, but no, I haven't planned out everything for
the next year.  If you have strong feelings about what should be done
in user and kernel space, feel free to share :)

DL> Argh ! I was hoping there was something else than the source code

The header file makes it pretty clear what is going on, but maybe the
Documentation/checkpoint/readme.txt will help.  Putting all the
details in such a documentation file would be rather silly at the
moment, given that new things are being added at a rapid rate and it
would duplicate the only description that matters, which is the
header file.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
