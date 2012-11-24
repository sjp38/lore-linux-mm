Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 096A06B004D
	for <linux-mm@kvack.org>; Sat, 24 Nov 2012 02:52:44 -0500 (EST)
Date: 24 Nov 2012 02:52:43 -0500
Message-ID: <20121124075243.28390.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
In-Reply-To: <20121123100222.21774.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mgorman@suse.de
Cc: dave@linux.vnet.ibm.com, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> tl;dr: Have installed Dave Hansen's patch as requested, rebooted.
>        Now it's a matter of waiting for lockup...

Well, the machine locked up again; it looks like Dave Hansen's patch
isn't the whie story.  Too bad I'm away from the office and can't get
at the console right now.

I'll get the extra information when I have the chance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
