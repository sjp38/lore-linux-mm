Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 043DA6B0085
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:24:25 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Resubmitting 1GB page shm patchkit
Date: Wed,  3 Oct 2012 15:24:22 -0700
Message-Id: <1349303063-12766-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patchkit allows to specify 1GB (and other) page sizes with
shmget(). This is useful for programs who are difficult to modify
to use mmap.

I got positive reviews last time I submitted this. I also get 
requests from various users who want it. So here's a resend with:

- Rebased to current mainline
- Retested
- Fixed a minor umount problem.

Please consider for merging.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
