Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 817BA6B0176
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 05:57:19 -0400 (EDT)
Message-ID: <4E0069FE.4000708@draigBrady.com>
Date: Tue, 21 Jun 2011 10:53:02 +0100
From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: sandy bridge kswapd0 livelock with pagecache
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de

I tried the 2 patches here to no avail:
http://marc.info/?l=linux-mm&m=130503811704830&w=2

I originally logged this at:
https://bugzilla.redhat.com/show_bug.cgi?id=712019

I can compile up and quickly test any suggestions.

cheers,
PA!draig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
