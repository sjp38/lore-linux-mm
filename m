Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 07A8A8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 16:38:13 -0500 (EST)
Received: from [127.0.0.1] (helo=anilinux.org)
	by atlantis.server4u.cz with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <mordae@anilinux.org>)
	id 1Px4bZ-0003NJ-PI
	for linux-mm@kvack.org; Tue, 08 Mar 2011 22:38:10 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Date: Tue, 08 Mar 2011 22:38:09 +0100
From: Mordae <mordae@anilinux.org>
Message-ID: <056c7b49e7540a910b8a4f664415e638@anilinux.org>
Subject: COW userspace memory mapping question
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

first let me apologize if I've picked a wrong address.

Question: Is it possible to create a copy-on-write copy
          of a MAP_PRIVATE|MAP_ANONYMOUS memory mapping
          in the user space? Effectively a snapshot of
          memory region.

          I understand that clone() optionally does this
          on much larger scale, but that's not really it.

Best regards,
    Jan Dvorak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
