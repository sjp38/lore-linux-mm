Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6QHZiRX375782
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 13:35:44 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6QHZkuN096366
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 11:35:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6QHZhtW012107
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 11:35:43 -0600
Subject: Memory pressure handling with iSCSI
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-Xm32wxTW65S3Kwp+ug1O"
Date: Tue, 26 Jul 2005 10:35:30 -0700
Message-Id: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: akpm@osdl.org
List-ID: <linux-mm.kvack.org>

--=-Xm32wxTW65S3Kwp+ug1O
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Andrew,

After KS & OLS discussions about memory pressure, I wanted to re-do
iSCSI testing with "dd"s to see if we are throttling writes.  

I created 50 10-GB ext3 filesystems on iSCSI luns. Test is simple
50 dds (one per filesystem). System seems to throttle memory properly
and making progress. (Machine doesn't respond very well for anything
else, but my vmstat keeps running - 100% sys time).

Thanks,
Badari



--=-Xm32wxTW65S3Kwp+ug1O
Content-Disposition: attachment; filename=vmstat.out
Content-Type: text/plain; name=vmstat.out; charset=UTF-8
Content-Transfer-Encoding: 7bit

procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
38 96  30500  43360  16612 6671064    2    0   103 11079 9860  2960  0 100  0  0
43 94  30500  43872  16704 6670460    0    0   124 11232 10993  3624  0 100  0  0
41 95  30500  44756  16780 6670304   22    0    41 11615 10864  3702  0 100  0  0
43 91  30500  43392  16580 6672096    6    0    11 10885 9736  2528  0 100  0  0
44 88  30500  43268  16468 6672204    6    0    14 12084 10361  1971  0 100  0  0
42 90  30500  43640  16556 6672116    0    0    26 12094 10447  3550  0 100  0  0
45 90  30500  46120  16584 6670016    6    0    22 11546 10690  3815  0 100  0  0
42 89  30500  43516  16560 6672564   11    0    48 12902 9368  3464  0 100  0  0
40 91  30500  43640  16572 6671540    6    0    87 10866 9253  2943  0 100  0  0
37 90  30500  43516  16608 6672040    6    0    25 14411 9374  2595  0 100  0  0
36 99  30500  43268  16568 6672080    0    0    23 14071 9524  2401  0 100  0  0
36 93  30500  43268  16596 6671504    6    0    16 11502 9403  3185  0 100  0  0
33 91  30500  43392  16588 6671540    0    0    11 10191 9837  3374  0 100  0  0
33 91  30500  43392  16552 6672092    0    0    15 11762 9703  2915  0 100  0  0
33 90  30500  43268  16648 6671480    0    0   131 11692 9784  3154  0 100  0  0
33 97  30500  43640  16640 6672004    0    0    18  9253 9491  1998  0 100  0  0



--=-Xm32wxTW65S3Kwp+ug1O--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
