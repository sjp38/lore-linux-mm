Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D8BE8D0001
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 00:24:52 -0400 (EDT)
Date: Tue, 2 Nov 2010 05:14:16 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
Message-ID: <alpine.LNX.2.00.1011020513200.11973@swampdragon.chaosbits.net>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Nov 2010, Ben Gamari wrote:

> This will allow distributions to tune this important vm parameter in a more
> self-contained manner.
> 
> Signed-off-by: Ben Gamari <bgamari.foss@gmail.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Doesn't mean much, but this gets my ACK now :-)

Acked-by: Jesper Juhl <jj@chaosbits.net>

-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
