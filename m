Received: from [192.168.0.9] (av-ops.corp.av.com [16.3.176.7])
	by ladakh.smo.av.com (8.9.3/8.9.3) with ESMTP id MAA19055
	for <linux-mm@kvack.org>; Sat, 22 Apr 2000 12:35:32 -0700 (PDT)
Date: Sat, 22 Apr 2000 12:35:33 -0700
Subject: mmap64?
From: Jason Titus <jason.titus@av.com>
Message-ID: <B5274D15.56A6%jason.titus@av.com>
Mime-version: 1.0
Content-type: text/plain; charset="US-ASCII"
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We have been doing some work with > 2GB files under x86 linux and have run
into a fair number of issues (instability, non-functioning stat calls, etc).

One that just came up recently is whether it is possible to memory map >2GB
files.  Is this a possibility, or will this never happen on 32 bit
platforms?

Thanks for any help,

Jason.
jason.titus@av.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
