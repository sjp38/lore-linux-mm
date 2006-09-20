Subject: Re: [patch00/05]: Containers(V2)- Introduction
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <451172AB.2070103@yahoo.com.au>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
	 <4510D3F4.1040009@yahoo.com.au>
	 <Pine.LNX.4.64.0609200925280.30572@schroedinger.engr.sgi.com>
	 <451172AB.2070103@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Sep 2006 18:40:28 +0100
Message-Id: <1158774028.7705.26.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, rohitseth@google.com, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ar Iau, 2006-09-21 am 02:56 +1000, ysgrifennodd Nick Piggin:
> But as I said above, I don't know what the containers and workload
> management people want exactly... The recent discussions about using
> nodes and cpusets for memory workload management does seem like a
> promising idea, and if it would avoid the need for this kind of
> per-page tracking entirely, then that would probably be even better.

I think you can roughly break it down to

- I want one group of users not to be able to screw another group of
users or the box but don't care about anything else. The basic
beancounter stuff handles this. Generally they also want maximal
sharing.

- I want to charge people for portions of machine use (mostly accounting
and some fairness)

- I don't want any user to be able to hog the system to the harm of the
others but don't care about overcommit of idle resources (think about
the 5000 apaches on a box case)

- I want to be able to divide resources reasonably accurately all the
time between groups of users

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
