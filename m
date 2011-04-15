Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75A43900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 06:01:14 -0400 (EDT)
From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Subject: [PATCH 0/1] mm: make read-only accessors take const pointer parameters
Date: Fri, 15 Apr 2011 12:56:16 +0300
Message-Id: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Sending this one its own as it either becomes an enabler for further
related patches, or if nacked, shuts the door on them. Better to test
the water before investing too much time on such things.

Whilst following a few static code analysis warnings, it became clear
that either the tool (which I believe is considered practically state of
the art) was very dumb when sniffing into called functions, or that a
simple const flag would either help it not make the incorrect paranoid
assumptions that it did, or help me dismiss the report as a false
positive more quickly.

Of course, this is core core code, and shouldn't be diddled with lightly,
but it's because it's core code that it's an enabler.

Awaiting the judgement of the Solomons,
Cheers,
Phil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
