Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA04296
	for <linux-mm@kvack.org>; Thu, 11 Jun 1998 10:19:11 -0400
Subject: Re: TODO list: who is working on what?
References: <Pine.LNX.3.95.980611111725.1742A-100000@localhost>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 11 Jun 1998 09:28:12 -0500
In-Reply-To: Rik van Riel's message of Thu, 11 Jun 1998 11:19:07 +0200 (MET DST)
Message-ID: <m17m2o57yb.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "Rik" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

Rik> Hi,
Rik> I'm currently trying to make a Linux MM TODO list,
Rik> keeping track of what needs to be done and who is
Rik> / will be working on what.

Rik> I want to do this to make sure that no conflicting/
Rik> double effort is being done where one superior solution
Rik> could have been coded...

My current projects include:
- Large file support in the page cache.
- Write back caching through the page cache.
- Ability to use swap for non-process things. Shared memory etc.

Rik> grtz,

Rik> Rik.
Rik> +-------------------------------------------------------------------+
Rik> | Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
Rik> | Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
Rik> +-------------------------------------------------------------------+
