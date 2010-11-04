Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6C6486B00A9
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 22:44:15 -0400 (EDT)
Received: by qwi2 with SMTP id 2so823280qwi.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 19:44:13 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <AANLkTimDPdDHAg0Odp0WchOLKh3OUSOWX7_0ps8eizFk@mail.gmail.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com> <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com> <87oca7evbo.fsf@gmail.com> <AANLkTimDPdDHAg0Odp0WchOLKh3OUSOWX7_0ps8eizFk@mail.gmail.com>
Date: Wed, 03 Nov 2010 22:44:11 -0400
Message-ID: <87eib1byf8.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2010 23:34:27 +0900, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> wrote:
> Hmm, then, can't we add a sysctl template config/script for generic
> sysctl values ?
>
That is one idea. Unfortunately, then we have something of a dependency
on out of tree userspace utilities.

> Adding this kind of CONFIG one by one seems not very helpful...
> 
This was definitely a concern of mine as well. In principle, a
distribution might want to tune any of the knobs in /proc/sys, so I
agree that adding them to Kconfig is a bit of a poor path to go down.
That being said, swappiness is an especially important tunable.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
