Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e4.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id PAA102358
	for <linux-mm@kvack.org>; Mon, 9 Oct 2000 15:07:12 -0400
Received: from d01ml244.pok.ibm.com (d01ml244.pok.ibm.com [9.117.200.44])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.93) with ESMTP id PAA39386
	for <linux-mm@kvack.org>; Mon, 9 Oct 2000 15:07:22 -0400
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <OF5AF00617.4E1330B9-ON85256973.00686895@pok.ibm.com>
From: "Hubertus Franke/Watson/IBM" <frankeh@us.ibm.com>
Date: Mon, 9 Oct 2000 15:06:12 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think what Ed was pointing out is that the SIG_DANGER signal approach
provides a good mean to inform applications that things are getting tight
and that further deterioration will result in process kills. Now providing
some integer value only gives you some edge, but since you don't know how
many other processes provided higher priority then you with regard to this
value, you can' make any assumption.
A process properly responding to the SIG_DANGER signal should release some
memory, e.g. it could do carbage collection and freeing of pages so that
the kernel can release them. They should get some credit for releaving the
memory pressure.
So first avoiding processes that can deal with SIG_DANGER seems a good
approach, while those processes still a target after this should be
identified by the priority mechanism discussed. I think, these are just
orthogonal issues.

-- Hubertus


Ingo Molnar <mingo@elte.hu>@kvack.org on 10/09/2000 02:01:48 PM

Please respond to mingo@elte.hu

Sent by:  owner-linux-mm@kvack.org


To:   Ed Tomlinson <tomlins@cam.org>
cc:   Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, Marco Colombo
      <marco@esi.it>, Rik van Riel <riel@conectiva.com.br>,
      linux-mm@kvack.org
Subject:  Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler



On Mon, 9 Oct 2000, Ed Tomlinson wrote:

> What about the AIX way?  When the system is nearly OOM it sends a
> SIG_DANGER signal to all processes.  Those that handle the signal are
> not initial targets for OOM...  Also in the SIG_DANGER processing they
> can take there own actions to reduce their memory usage... (we would
> have to look out for a SIG_DANGER handler that had a memory leak
> though)

i think 'importance' should be an integer value, not just a 'can it handle
SIG_DANGER' flag.

     Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
