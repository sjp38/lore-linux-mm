Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4D88D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 21:53:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1FDD63EE0BB
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:52:56 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07D4F45DE4E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:52:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D963645DE4D
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:52:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C764F1DB803A
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:52:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93F551DB802C
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:52:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [Q] PGPGIN underflow?
Message-Id: <20110324105307.1AF3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Mar 2011 10:52:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com

Hi all,

Recently, vmstast show crazy big "bi" value even though the system has
no stress. Is this known issue?

Thanks.


% vmstat 1
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0      0 1133060 151336 479708    0    0     0     0   50   50  0  0 100  0  0
 1  0      0 1133060 151336 479708    0    0     0     0   35   30  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   27   24  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   29   26  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   26   22  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   27   24  0  0 100  0  0
 1  0      0 1133060 151336 479708    0    0     0     0   45   49  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   62   54  1  0 99  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   54   56  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   28   24  0  1 99  0  0
 1  0      0 1133060 151336 479708    0    0     0     0   54   54  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   42   38  0  1 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   31   24  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   33   24  0  0 100  0  0
 1  0      0 1133060 151336 479708    0    0     0     0   56   58  1  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0  157  225  1  0 98  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   40   37  0  0 100  0  0
 0  0      0 1133060 151336 479708    0    0     0     0   51   47  0  0 100  0  0
 1  0      0 1133060 151336 479708    0    0     0     0   51   46  1  0 99  0  0
 0  0      0 1133060 151336 479708    0    0     0     0  296  418  2  0 97  0  0
 0  0      0 1133060 151336 479708    0    0     0     0  295  419  3  2 95  0  0
 0  0      0 1133060 151336 479708   16    0     0     0  313  449  3  1 96  0  0
 0  0      0 1132936 151336 479708    0    0 4294967293     0  331  448  5  1 95  0  0
 1  0      0 1132936 151336 479708    0    0     0     0  303  445  3  1 96  0  0
 0  0      0 1132936 151336 479708   16    0     0     0  308  433  3  1 96  0  0
 0  0      0 1132936 151336 479708    0    0     0     0  307  450  4  0 96  0  0
 1  0      0 1132936 151344 479704   96    0     0     0  255  222  6  1 93  0  0
 1  0      0 1132812 151344 479708    0    0 4294967293     0  397  310 11  1 88  0  0
 0  0      0 1132688 151344 479708    0    0 4294967293     0  410  365  9  1 90  0  0
 1  0      0 1132812 151344 479708    0    0     3     0   33   32  0  0 100  0  0
 0  0      0 1132812 151344 479708    0    0     0     0   31   23  0  0 100  0  0
 0  0      0 1132812 151344 479708    0    0     0     0   35   34  0  0 100  0  0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
