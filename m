From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:36:59 +0200
Message-Id: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 0/39] mm: 2.6.17-pr1 - generic page-replacement framework and 4 new policies
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi,

with OLS around the corner, I thought I'd repost all my page-replacement work
so people can get a quick peek at the current status. 
This should help discussion next week.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
