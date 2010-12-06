Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B1A6C6B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 01:05:24 -0500 (EST)
Date: Mon, 6 Dec 2010 01:05:20 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <474601132.104781291615520703.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1072296184.6551291445290387.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: mmotm-2010-11-23 panic at __init_waitqueue_head+0xd/0x1d
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: james toy <toyj@union.edu>
List-ID: <linux-mm.kvack.org>

OK, this turned out to be a known issue,
https://lkml.org/lkml/2010/11/22/15

Sorry for the noise.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
