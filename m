Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 228A36B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:45:01 -0500 (EST)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx4-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id oB12ixeg023016
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:44:59 -0500
Date: Tue, 30 Nov 2010 21:44:59 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <919384632.877731291171499343.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: oom is broken in mmotm 2010-11-09-15-31 tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, just a head-up. When testing oom for this tree, my workstation is immediately having no response to ssh, Desktop actions and so on apart from ping. I am trying to bisect but looks like git public server is having problem.

# git pull
fatal: read error: Connection reset by peer

# git clone git://zen-kernel.org/kernel/mmotm.git
Cloning into mmotm...
fatal: read error: Connection reset by peer

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
