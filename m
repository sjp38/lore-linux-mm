Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4136B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 07:57:41 -0400 (EDT)
Date: 14 Jun 2011 07:57:40 -0400
Message-ID: <20110614115740.32527.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: 3.0-rc1 stuck process in munmap()
In-Reply-To: <20110614114854.31801.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux@horizon.com

Update: I kiled vlc and a few other things in preparation for rebooting,
and firefox un-wedged itself.  Very confusing.

3.0-rc3 has compiled and I'm going to reboot anyway, but FWIW, it wasn't
quite as hard a lockup as I thought.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
