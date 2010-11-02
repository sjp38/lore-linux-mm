Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2077A6B0102
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 21:06:24 -0400 (EDT)
Date: Tue, 2 Nov 2010 09:04:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH] Add Kconfig option for default swappiness
Message-ID: <20101102010440.GA2684@localhost>
References: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com>
 <alpine.LNX.2.00.1011012108360.12889@swampdragon.chaosbits.net>
 <87wrowrd34.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87wrowrd34.fsf@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: Jesper Juhl <jj@chaosbits.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 01, 2010 at 04:41:35PM -0400, Ben Gamari wrote:
> On Mon, 1 Nov 2010 21:09:58 +0100 (CET), Jesper Juhl <jj@chaosbits.net> wrote:
> > Perhaps this help text should mention the fact that swapiness setting can 
> > be changed at runtime (regardless of the set default) by writing to 
> > /proc/sys/vm/swappiness ???
> > 
> This definitely wouldn't hurt. I'll respin with updated help text.

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
