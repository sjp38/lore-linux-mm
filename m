Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2F1876B012B
	for <linux-mm@kvack.org>; Wed, 13 May 2009 16:24:02 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090513161759.03a54ec0@flumedata.com>
Date: Wed, 13 May 2009 16:18:21 -0400
From: starlight@binnacle.cx
Subject: [Bug 12134] can't shmat() 1GB hugepage segment from
  second process more than one time
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

New life for old bug.

Reproduced under 2.6.29.1.

Also discerned separate hugepage fork() issue now reported
under bug 13302.

Sorry I keep forgetting to stay with e-mail.  Bugzillas
are easier to keep track of over many months.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
