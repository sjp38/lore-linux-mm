Received: from [192.168.1.207] ([192.168.1.207])
	by arianne.in.ishoni.com (8.11.6/Ishonir2) with ESMTP id h1B4l8L31773
	for <linux-mm@kvack.org>; Tue, 11 Feb 2003 10:17:09 +0530
Subject: hot and cold pages
From: Amol Kumar Lad <amolk@ishoni.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 11 Feb 2003 10:12:27 -0500
Message-Id: <1044976347.13957.19.camel@amol.in.ishoni.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
  I have a small question regarding 'per_cpu_pages' . What is
significance if maintaining 'hot' pages and 'cold' pages list. Are hot
pages something to do with L2 cache (on x86) ?
---
After going through code, I found out, any new page allocation (for file
read)is from cold page list and zero order pages are generally freed to
hot page list

-- Amol




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
