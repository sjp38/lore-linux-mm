Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9D98E6B01B4
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 11:40:55 -0400 (EDT)
Date: Sun, 6 Jun 2010 16:40:48 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: 2.6.35-rc2 : OOPS with LTP memcg regression test run.
Message-ID: <20100606154048.GJ31073@ZenIV.linux.org.uk>
References: <4C0BB98E.9030101@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C0BB98E.9030101@in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Sachin Sant <sachinp@in.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 06, 2010 at 08:36:54PM +0530, Sachin Sant wrote:

> And few more of these. Previous snapshot release 2.6.35-rc1-git5(6c5de280b6...)
> was good.

That's very odd, since
; git diff --stat 6c5de280b6..v2.6.35-rc2         
 Makefile                             |    2 +-
 drivers/gpu/drm/i915/intel_display.c |    9 +++++++
 fs/ext4/inode.c                      |   40 +++++++++++++++++++--------------
 fs/ext4/move_extent.c                |    3 ++
 4 files changed, 36 insertions(+), 18 deletions(-)
;
and nothing of that looks like good candidates...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
