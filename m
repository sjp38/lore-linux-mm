Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2D96B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 18:09:23 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: RFC: Implement hwpoison on free for soft offlining
Date: Thu,  7 Oct 2010 00:09:10 +0200
Message-Id: <1286402951-1881-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

Here's a somewhat experimental patch to improve soft offlining
in hwpoison, but allowing hwpoison on free for not directly
freeable page types. It should work for nearly all
left over page types that get eventually freed, so this makes
soft offlining nearly universal. The only non handleable page
types are now pages that never get freed.

Drawback: It needs an additional page flag. Cannot set hwpoison
directly because that would not be "soft" and cause errors.

Since the flags are scarce on 32bit I only enabled it on 64bit.

Comments?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
