Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B06236B006C
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 18:49:35 -0500 (EST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCH] kmemleak: Add support for memory hotplug
Date: Tue, 15 Nov 2011 15:49:08 -0800
Message-Id: <1321400949-1852-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, mingo@elte.hu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org

Currently, kmemleak is not supported with memory hotplug. This has
been discussed before[1] but never really went anywhere. Catalin's
other suggestion was to add callbacks for memory hotplug but given
there is now a nice lock_memory_hotplug function, this seems like
the right place to call it. Down the road call backs could be added
but this should hopefully enable hotplug to be used with kmemleak.

-Laura

[1] https://lkml.org/lkml/2010/3/22/395

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
