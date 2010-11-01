Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A9D6D6B0093
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 16:41:45 -0400 (EDT)
Received: by gwb11 with SMTP id 11so3984927gwb.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 13:41:42 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [RFC PATCH] Add Kconfig option for default swappiness
In-Reply-To: <alpine.LNX.2.00.1011012108360.12889@swampdragon.chaosbits.net>
References: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com> <alpine.LNX.2.00.1011012108360.12889@swampdragon.chaosbits.net>
Date: Mon, 01 Nov 2010 16:41:35 -0400
Message-ID: <87wrowrd34.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Nov 2010 21:09:58 +0100 (CET), Jesper Juhl <jj@chaosbits.net> wrote:
> Perhaps this help text should mention the fact that swapiness setting can 
> be changed at runtime (regardless of the set default) by writing to 
> /proc/sys/vm/swappiness ???
> 
This definitely wouldn't hurt. I'll respin with updated help text.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
