Received: from ucspost.ucs.co.za (IDENT:root@mailgw1.ucs.co.za [196.23.43.254])
	by ucs.co.za (8.11.2/8.11.2) with ESMTP id f6SCMgQ18195
	for <linux-mm@kvack.org>; Sat, 28 Jul 2001 14:22:42 +0200
Received: from jhb.ucs.co.za (IDENT:root@jhb.ucs.co.za [172.31.1.73]) by ucspost.ucs.co.za (8.9.3/8.7.3) with ESMTP id OAA21992 for <linux-mm@kvack.org>; Sat, 28 Jul 2001 14:22:42 +0200
Received: from bds.ucs.co.za (bds@bds.ucs.co.za [172.31.1.36])
	by jhb.ucs.co.za (8.9.3/8.8.7) with ESMTP id OAA23543
	for <linux-mm@kvack.org>; Sat, 28 Jul 2001 14:25:11 +0200
Subject: oom-kill looping
From: Berend De Schouwer <bds@jhb.ucs.co.za>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 28 Jul 2001 14:22:41 +0200
Message-Id: <996322962.1350.43.camel@bds.ucs.co.za>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I've got a machine that has been crashing more-or-less weekly due to
running out of memory.  I've noticed an oddity in oom-kill.  It loops
'Out of Memory: Killed process 12345 (abc).'  The same PID is listed
continuously.  This is with kernel 2.4.x.  With the 2.2 series it just
hung.

Is it a good idea to add checks oom_kill.c in badness() like:
  if is_not_runnable(p)
    return 0;
  if has_pending_term_or_kill(p)
    return 0;

and if so, would (p->state != 0) and signal_pending(p) be the way to do
it?  How would you check for just the SIGKILL or SIGTERM signal?

It takes about a week to trigger this OOM, so trials are slow.

--
Berend De Schouwer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
