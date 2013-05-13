Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3C4D66B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:16:51 -0400 (EDT)
From: Oskar Andero <oskar.andero@sonymobile.com>
Subject: [RFC PATCH 0/2] return value from shrinkers
Date: Mon, 13 May 2013 16:16:33 +0200
Message-ID: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Oskar Andero <oskar.andero@sonymobile.com>

Hi,

In a previous discussion on lkml it was noted that the shrinkers use the
magic value "-1" to signal that something went wrong.

This patch-set implements the suggestion of instead using errno.h values
to return something more meaningful.

The first patch simply changes the check from -1 to any negative value and
updates the comment accordingly.

The second patch updates the shrinkers to return an errno.h value instead
of -1. Since this one spans over many different areas I need input on what is
a meaningful return value. Right now I used -EBUSY on everything for consitency.

What do you say? Is this a good idea or does it make no sense at all?

Thanks!

-Oskar

Oskar Andero (2):
  mm: vmscan: let any negative return value from shrinker mean error
  Clean-up shrinker return values

 drivers/staging/android/ashmem.c     | 2 +-
 drivers/staging/zcache/zcache-main.c | 2 +-
 fs/gfs2/glock.c                      | 2 +-
 fs/gfs2/quota.c                      | 2 +-
 fs/nfs/dir.c                         | 2 +-
 fs/ubifs/shrinker.c                  | 2 +-
 include/linux/shrinker.h             | 5 +++--
 mm/vmscan.c                          | 2 +-
 net/sunrpc/auth.c                    | 2 +-
 9 files changed, 11 insertions(+), 10 deletions(-)

-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
