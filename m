Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7ONcowH005720 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 08:38:50 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7ONcn0B017041 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 08:38:49 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s2.gw.fujitsu.co.jp (8.12.10)
	id i7ONcncr016770 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 08:38:49 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2Z00BMI5ON59@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed, 25 Aug 2004 08:38:48 +0900 (JST)
Date: Wed, 25 Aug 2004 08:43:58 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC/PATCH] free_area[] bitmap elimination[0/3]
In-reply-to: <1093366431.1009.28.camel@nighthawk>
Message-id: <412BD2BE.8070007@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <412B32D1.10005@jp.fujitsu.com> <1093366431.1009.28.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
>>+#define set_page_order(page,order)\
>>+        do {\
>>+            (page)->private = (order);\
>>+            SetPagePrivate((page));\
>>+        } while(0)
>>+#define invalidate_page_order(page) ClearPagePrivate((page))
>>+#define page_order(page) ((page)->private)
>>+
>>+/*
> 
> 
> Can these be made into static inline functions instead of macros?

Okay, I'd like to change these macros to static inline functions.

-- Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
