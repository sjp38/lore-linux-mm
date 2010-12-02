Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 059E76B00C1
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 22:11:14 -0500 (EST)
Date: Wed, 1 Dec 2010 22:11:12 -0500 (EST)
From: caiqian@redhat.com
Message-ID: <1607175419.1020111291259472474.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1415319777.1020071291259410217.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: " \"linux-mm\"; \"Rik van Riel\" <riel@redhat.com>; \"Wu Fengguang\" <fengguang.wu@intel.com>; \"H. Peter Anvin\" <hpa@zytor.com>; \"Linus Torvalds" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> Things are known to be broken between
> d065bd810b6deb67d4897a14bfe21f8eb526ba99 and
> d88c0922fa0e2c021a028b310a641126c6d4b7dc. CAI, do you have that in
> your tree ? Also, can you test at
> d065bd810b6deb67d4897a14bfe21f8eb526ba99 with
> d88c0922fa0e2c021a028b310a641126c6d4b7dc cherry-picked on ?
Hi Michel, the mmotm tree did not include d88c0922fa0e2c021a028b310a641126c6d4b7dc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
