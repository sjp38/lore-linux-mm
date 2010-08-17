Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B2E006B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 07:04:41 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7HB4duS020405
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Tue, 17 Aug 2010 20:04:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7808545DE4F
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:04:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5756645DE4E
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:04:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FE101DB8040
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:04:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F27281DB803C
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:04:38 +0900 (JST)
Message-ID: <325E0A25FE724BA18190186F058FF37E@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
Subject: compaction: trying to understand the code
Date: Tue, 17 Aug 2010 20:08:54 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-15";
	reply-type=response
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

I am trying to understand the following code in isolate_migratepages
function. I have a question regarding this.

---
 while (unlikely(too_many_isolated(zone))) {
  congestion_wait(BLK_RW_ASYNC, HZ/10);

  if (fatal_signal_pending(current))
   return 0;
 }

---

I have seen that in some cases this while loop never exits
because too_many_isolated keeps returning true for ever.
And hence the process hangs. Is this intended behaviour?
What is it that is supposed to change the "too_many_isolated" situation?
In other words, what is it that is supposed to increase the "inactive"
or decrease the "isolated" so that isolated > inactive becomes false?

Best regards
Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
