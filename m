Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA03143
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 01:28:52 -0500
Subject: Re: [PATCH] swapin readahead
References: <87vhjvkccu.fsf@atlas.CARNet.hr> <Pine.LNX.3.96.981201192554.4046A-100000@mirkwood.dummy.home> <199812021735.RAA04489@dax.scot.redhat.com> <87d862gs3h.fsf@atlas.CARNet.hr>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 02 Dec 1998 23:25:38 -0600
In-Reply-To: Zlatko Calusic's message of "02 Dec 1998 22:18:58 +0100"
Message-ID: <m1af15iyp9.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

ZC> Trying 2.1.131-2, I'm mostly satisfied with MM workout, but...

ZC> Still, I have a feeling that limit imposed on cache growth is now too
ZC> hard, unlike kernels from the 2.1.1[01]? era, that had opposite
ZC> problems (excessive cache growth during voluminous I/O operations).

My gut reaction is that we need a check in swap_out to see if we have
written out a swap_cluster or some other indication that we have
started all of the disk i/o that is reasonable for now and need to
switch to something else.

This should have the same effect as the switches with the limits on
the swap cache but more autobalancing.  I'm nervous of a kernel that
needs small limits on it's disk cache to work correctly.

ZC> What I wanted to ask is: do you guys share my opinion, and what
ZC> changes would you like to see before 2.2 comes out?

One thing worth putting in.  Probably before to 2.2 but definentily
before any swap page readahead is done is to start using brw_page
for swapfiles.  I don't know about synchronous cases, but in the when
asynchronous operation is important it improves swapfile performance
immensely.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
