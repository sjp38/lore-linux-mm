Received: from mailgate4.nec.co.jp ([10.7.69.197])
	by TYO202.gate.nec.co.jp (8.11.6/3.7W01080315) with ESMTP id g6O3Hqe06417
	for <linux-mm@kvack.org>; Wed, 24 Jul 2002 12:17:52 +0900 (JST)
Received: from mailsv.nec.co.jp (mailgate51.nec.co.jp [10.7.69.196]) by mailgate4.nec.co.jp (8.11.6/3.7W-MAILGATE-NEC) with ESMTP
	id g6O3Hqi16781 for <linux-mm@kvack.org>; Wed, 24 Jul 2002 12:17:52 +0900 (JST)
Received: from mailsv.bs1.fc.nec.co.jp (venus.hpc.bs1.fc.nec.co.jp [10.34.77.164]) by mailsv.nec.co.jp (8.11.6/3.7W-MAILSV-NEC) with ESMTP
	id g6O3Hph05770 for <linux-mm@kvack.org>; Wed, 24 Jul 2002 12:17:51 +0900 (JST)
Received: from localhost (pingu.hpc.bs1.fc.nec.co.jp [10.34.77.220])
	by mailsv.bs1.fc.nec.co.jp (8.12.0/3.7W-HPC5.2F(mailsv)01041614) with ESMTP id g6O39oLw022935
	for <linux-mm@kvack.org>; Wed, 24 Jul 2002 12:09:50 +0900 (JST)
Subject: Help, limiting pagecaches
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20020724121840X.miyoshi@hpc.bs1.fc.nec.co.jp>
Date: Wed, 24 Jul 2002 12:18:40 +0900
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
