Received: from mailgate4.nec.co.jp ([10.7.69.197])
	by TYO202.gate.nec.co.jp (8.11.6/3.7W01080315) with ESMTP id g6P4Kje09046
	for <linux-mm@kvack.org>; Thu, 25 Jul 2002 13:20:45 +0900 (JST)
Received: from mailsv4.nec.co.jp (mailgate51.nec.co.jp [10.7.69.196]) by mailgate4.nec.co.jp (8.11.6/3.7W-MAILGATE-NEC) with ESMTP
	id g6P4Kii16268 for <linux-mm@kvack.org>; Thu, 25 Jul 2002 13:20:44 +0900 (JST)
Received: from mailsv.bs1.fc.nec.co.jp (venus.d2.bs1.fc.nec.co.jp [10.34.77.164]) by mailsv4.nec.co.jp (8.11.6/3.7W-MAILSV4-NEC) with ESMTP
	id g6P4Keo17938 for <linux-mm@kvack.org>; Thu, 25 Jul 2002 13:20:41 +0900 (JST)
Received: from localhost (pingu.hpc.bs1.fc.nec.co.jp [10.34.77.220])
	by mailsv.bs1.fc.nec.co.jp (8.12.0/3.7W-HPC5.2F(mailsv)01041614) with ESMTP id g6P4CYLw002453
	for <linux-mm@kvack.org>; Thu, 25 Jul 2002 13:12:34 +0900 (JST)
Subject: Limiting pagecaches
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20020725132127U.miyoshi@hpc.bs1.fc.nec.co.jp>
Date: Thu, 25 Jul 2002 13:21:27 +0900
From: miyoshi@hpc.bs1.fc.nec.co.jp
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, all

Is there any way to limit the size of pagecaches?

I observed that performance of some memory hog benchmark
does not stable, depending on the pagecache size.
I think it is natural behavior of VM subsystem,
but some user care for perfomance stability :-<

I saw /proc/sys/vm/pagecaches sysctl entry in early 2.4,
but "max_percent" value was not used in the source code.
On newer kernel, entry itself seems disappeared...

Is there any trial to provide feature to limit pagecache?

Thanks,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
