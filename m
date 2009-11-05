Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D52366B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 17:26:11 -0500 (EST)
Date: Thu, 5 Nov 2009 14:26:08 -0800 (PST)
From: Kenneth Crudup <kenny@panix.com>
Subject: Re: [TuxOnIce-users] strange OOM receiving a wireless network packet
 on a SLUB system
In-Reply-To: <c7a347a10911050428i7b2b5080y64f36f3cd8913ccc@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0911051359230.19277@hp9800.localdomain>
References: <c7a347a10911041421u35b102behe0ed2d94506680c1@mail.gmail.com>
 <87zl71lt7l.fsf_-_@spindle.srvr.nix> <20091105094611.2081.A69D9226@jp.fujitsu.com>
 <c7a347a10911050428i7b2b5080y64f36f3cd8913ccc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: TuxOnIce users' list <tuxonice-users@lists.tuxonice.net>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Thu, 5 Nov 2009, Dominik Stadler wrote:

> As Kenneth indicated it is a known issue in .31

Oh, and the workaround (sorry, I'd forgotten to reply with it!) is to
set the option amsdu_size_8K to "0" for module iwlagn (or on the boot
parameter line).

	-Kenny

-- 
Kenneth R. Crudup  Sr. SW Engineer, Scott County Consulting, Los Angeles
O: 3630 S. Sepulveda Blvd. #138, L.A., CA 90034-6809      (888) 454-8181

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
