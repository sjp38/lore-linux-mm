Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id E98A06B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 23:22:58 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so781022vbb.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 20:22:57 -0700 (PDT)
Message-ID: <4F98BF90.9050703@gmail.com>
Date: Wed, 25 Apr 2012 23:22:56 -0400
From: Joe Ceklosky <jfceklosky@gmail.com>
MIME-Version: 1.0
Subject: Possible 32-bit PAE kernel I/O slow down with 3.3.X
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


I have notice significant slow downs with disk I/O on a 32-bit PAE 3.3.X 
kernels.
The test machine has 16GB memory, Intel i5 CPU, Intel
motherboard, and an Intel 160GB SSD.  I copied 536M from one partition 
on an SSD to another.


Test 1:
kernel 3.3.2 32-bit PAE with kernel parm mem=3G

time cp -ra testdir/ /tmp
real    0m8.989s
user    0m0.094s
sys     0m1.080s


Test 2:
kernel 3.3.2 32-bit PAE

time cp -ra testdir/ /tmp
real    1m17.068s
user    0m0.173s
sys     0m2.149s


Also I tested kernel 3.2.16 32-bit PAE with no memory limits and it
was in line with test 1.

Am I doing something wrong or could something have been broken in PAE 
with kernel 3.3.X?



Thanks,
Joe Ceklosky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
