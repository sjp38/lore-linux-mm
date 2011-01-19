Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1AF6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 23:38:55 -0500 (EST)
Date: Wed, 19 Jan 2011 13:38:47 +0900
From: Norbert Preining <preining@logic.at>
Subject: Re: dirty throttling v5 for 2.6.37-rc7+
Message-ID: <20110119043847.GF29887@gamma.logic.tuwien.ac.at>
References: <20101224170418.GA3405@gamma.logic.tuwien.ac.at> <20101225030019.GA25383@localhost> <20101225052736.GA5649@gamma.logic.tuwien.ac.at> <20101225073850.GA1626@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101225073850.GA1626@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Fengguang,

On Sa, 25 Dez 2010, Wu Fengguang wrote:
> > > I just created branch "dirty-throttling-v5" based on today's linux-2.6 head.

One request, please update for 38-rc1, thanks.

> It's already a test to simply run it in your environment, thanks!
> Whether it runs fine or not, they will make valuable feedbacks :)

It runs fine, and feels a bit better when I trash my hard disk with
subversion. Still some times the whole computer is unresponsive,
the mouse pointer when entering the terminal of the subversion process
disappearing, but without it it is a bit worse.

Thanks and all the best

Norbert
------------------------------------------------------------------------
Norbert Preining            preining@{jaist.ac.jp, logic.at, debian.org}
JAIST, Japan                                 TeX Live & Debian Developer
DSA: 0x09C5B094   fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 B094
------------------------------------------------------------------------
Program aborting:
Close all that you have worked on.
You ask far too much.
                       --- Windows Error Haiku

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
