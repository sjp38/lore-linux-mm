Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E13896B00CC
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 12:38:40 -0400 (EDT)
Received: by iwn38 with SMTP id 38so7891445iwn.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 09:38:39 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 2 Nov 2010 19:32:40 +0300
Message-ID: <AANLkTino-GJTpmved=SjmN2O_dN=fhrS+vVfHAPoKQ6y@mail.gmail.com>
Subject: Low priority writers make realtime processes thrashing
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

When I run few "hard-writers" I get problems with my 15 realtime
processes (do some very small writes, just 2 pages per-time): they
start thrashing. I thought it's caused by write-back and was waiting
for Greg Tellen's per-cgroup dirty page accounting patch. Before
testing it I tried to change threshold in
page-writeback.c:get_dirty_limits(), I set dirty_ratio for RT process
80% (instead of just extra dirty / 4), but it didn't help me. What
else can cause problems?
I'm linux kernel newbie and will appreciate any addvices.

-- 
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
