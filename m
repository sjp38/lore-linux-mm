Message-ID: <4510D3F4.1040009@yahoo.com.au>
Date: Wed, 20 Sep 2006 15:39:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch00/05]: Containers(V2)- Introduction
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
In-Reply-To: <1158718568.29000.44.camel@galaxy.corp.google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: no To-header on input <unlisted-recipients>, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rohit Seth wrote:

>Containers:
>
>
[...]

>This is based on lot of discussions over last month or so.  I hope this
>patch set is something that we can agree and more support can be added
>on top of this.  Please provide feedback and add other extensions that
>are useful in the TODO list.
>

Hi Rohit,

Sorry for the late reply. I was just about to comment on your earlier
patchset but I will do so here instead.

Anyway I don't think I have much to say other than: this is almost
exactly as I had imagined the memory resource tracking should look
like. Just a small number of hooks and a very simple set of rules for
tracking allocations. Also, the possibility to track kernel
allocations as a whole rather than at individual callsites (which
shouldn't be too difficult to implement).

If anything I would perhaps even argue for further cutting down the
number of hooks and add them back as they prove to be needed.

I'm not sure about containers & workload management people, but from
a core mm/ perspective I see no reason why this couldn't get in,
given review and testing. Great!

Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
