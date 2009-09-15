Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD406B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 07:45:16 -0400 (EDT)
From: Ed Tomlinson <edt@aei.ca>
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
Date: Tue, 15 Sep 2009 07:45:14 -0400
References: <200909100215.36350.ngupta@vflare.org> <d760cf2d0909142339i30d74a9dic7ece86e7227c2e2@mail.gmail.com> <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
In-Reply-To: <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200909150745.16265.edt@aei.ca>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org, Ingo Molnar <mingo@elte.hu>, =?iso-8859-1?q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 15 September 2009 03:30:23 you wrote:
> > So, its extremely difficult to wait for the proper fix.
> 
> Then make ramzswap depend on !CONFIG_ARM. In any case, CONFIG_ARM bits
> really don't belong into drivers/block.

Problem is that ramzswap is usefull on boxes like the n800/n810...  So this is a bad
suggestion from my POV.    How about a comment saying this code goes when the 
fix arrives???

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
