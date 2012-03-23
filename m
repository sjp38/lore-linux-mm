Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9E3FE6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 04:05:27 -0400 (EDT)
Received: by eaal1 with SMTP id l1so1081715eaa.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 01:05:25 -0700 (PDT)
Message-ID: <4F6C2E9B.9010200@gmail.com>
Date: Fri, 23 Mar 2012 16:04:43 +0800
From: bill4carson <bill4carson@gmail.com>
MIME-Version: 1.0
Subject: Why memory.usage_in_bytes is always increasing after every mmap/dirty/unmap
 sequence
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi, all

I'm playing with memory cgroup, I'm a bit confused why
memory.usage in bytes is steadily increasing at 4K page pace
after every mmap/dirty/unmap sequence.

On linux-3.6.34.10/linux-3.3.0-rc5
A simple test case does following:

a) mmap 128k memory in private anonymous way
b) dirty all 128k to demand physical page
c) print memory.usage_in_bytes  <-- increased at 4K after every loop
d) unmap previous 128 memory
e) goto a) to repeat


And when the test case exit, memory.usage_in_bytes is not *ZERO*, but
the previous increased value.

I'm puzzled about what I saw, can anyone please give me some tips
to understand this?


Thanks in advance.

-- 
Love each day!

--bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
