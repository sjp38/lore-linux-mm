Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 04DEF6B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 10:10:26 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Huge page counter speedup complete
Date: Sat, 31 Mar 2012 07:09:55 -0700
Message-Id: <1333202997-19550-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tim.c.chen@linux.intel.com, linux-mm@kvack.org

Eliminate some hot cache lines in mm_struct for THP that showed up
in profiling.

This is a two patch patchkit, but the earlier submission only included
one. No code changes. Sorry about that.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
