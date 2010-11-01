Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 101168D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 08:43:28 -0400 (EDT)
Date: Mon, 1 Nov 2010 08:43:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] Add Kconfig option for default swappiness
Message-ID: <20101101124322.GG840@cmpxchg.org>
References: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 31, 2010 at 02:08:28PM -0400, Ben Gamari wrote:
> This will allow distributions to tune this important vm parameter in a more
> self-contained manner.

What's wrong with sticking

	vm.swappiness = <your value>

into the shipped /etc/sysctl.conf?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
