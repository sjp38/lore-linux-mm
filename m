Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA05906
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 10:29:13 -0500
Subject: Re: [PATCH] swapin readahead
References: <87vhjvkccu.fsf@atlas.CARNet.hr> <Pine.LNX.3.96.981201192554.4046A-100000@mirkwood.dummy.home> <199812021735.RAA04489@dax.scot.redhat.com> <87d862gs3h.fsf@atlas.CARNet.hr> <m1af15iyp9.fsf@flinx.ccr.net> <8767bt7gge.fsf@atlas.CARNet.hr>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 03 Dec 1998 09:39:48 -0600
In-Reply-To: Zlatko Calusic's message of "03 Dec 1998 09:55:13 +0100"
Message-ID: <m1vhjtcjzv.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

ZC> Speaking about swap files (as opposed to swap partitions) what is the
ZC> reason for synchronous operation when swapping to them, at first
ZC> place? Races?

It appears it was implmented that way long originally and no one has
changed the code.  It is almost trivial to change to using brw_page.

In my shmfs code I have that change, though I haven't tried it in a while.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
