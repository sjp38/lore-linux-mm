Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E67CA6B0087
	for <linux-mm@kvack.org>; Sat, 25 Dec 2010 00:27:42 -0500 (EST)
Date: Sat, 25 Dec 2010 14:27:36 +0900
From: Norbert Preining <preining@logic.at>
Subject: Re: dirty throttling v5 for 2.6.37-rc7+
Message-ID: <20101225052736.GA5649@gamma.logic.tuwien.ac.at>
References: <20101224170418.GA3405@gamma.logic.tuwien.ac.at> <20101225030019.GA25383@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101225030019.GA25383@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Wu,

merry christmas to everyone!

> I just created branch "dirty-throttling-v5" based on today's linux-2.6 head.

Thanks, pulled, built, rebooting.

I was running v1 for quite some time, without some planned testing.
Do you want me to do some more planned testing?

I am running a sony laptop with debian/sid, doing some heavy disk io
stuff (svn up on *big* repositories).

Best wishes

Norbert
------------------------------------------------------------------------
Norbert Preining            preining@{jaist.ac.jp, logic.at, debian.org}
JAIST, Japan                                 TeX Live & Debian Developer
DSA: 0x09C5B094   fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 B094
------------------------------------------------------------------------
LOUTH (n.)
The sort of man who wears loud check jackets, has a personalised
tankard behind the bar and always gets served before you do.
			--- Douglas Adams, The Meaning of Liff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
