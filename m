Message-ID: <4255BCC1.9000509@engr.sgi.com>
Date: Thu, 07 Apr 2005 18:05:37 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: question on page-migration code
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Well, even my previous description is not quite correct.
Here are the times for a series of 20 migrations,
from nodes 0-3 to 4-7, and then back again:

0.134u 1.425s 0:02.98 52.0%     0+0k 0+0io 1pf+0w
0.124u 0.395s 3:22.11 0.2%      0+0k 0+0io 24pf+0w
0.154u 1.494s 0:03.03 54.1%     0+0k 0+0io 8pf+0w
0.134u 1.137s 1:04.38 1.9%      0+0k 0+0io 28pf+0w
0.119u 0.723s 1:20.16 1.0%      0+0k 0+0io 8pf+0w
0.142u 1.299s 0:39.06 3.6%      0+0k 0+0io 28pf+0w
0.124u 0.526s 2:20.03 0.4%      0+0k 0+0io 0pf+0w
0.135u 1.336s 0:22.18 6.5%      0+0k 0+0io 0pf+0w
0.125u 1.128s 0:36.73 3.3%      0+0k 0+0io 8pf+0w
0.129u 1.099s 0:59.17 2.0%      0+0k 0+0io 28pf+0w
0.130u 0.679s 1:53.12 0.7%      0+0k 0+0io 8pf+0w
0.139u 1.193s 0:52.88 2.4%      0+0k 0+0io 28pf+0w
0.121u 0.621s 1:57.64 0.6%      0+0k 0+0io 8pf+0w
0.127u 1.241s 0:43.46 3.1%      0+0k 0+0io 28pf+0w
0.127u 0.734s 1:19.92 1.0%      0+0k 0+0io 8pf+0w
0.126u 1.317s 0:51.17 2.7%      0+0k 0+0io 28pf+0w
0.137u 0.613s 2:19.44 0.5%      0+0k 0+0io 8pf+0w
0.113u 1.290s 0:42.33 3.3%      0+0k 0+0io 28pf+0w
0.125u 0.538s 2:06.91 0.5%      0+0k 0+0io 7pf+0w
0.128u 1.328s 0:41.59 3.4%      0+0k 0+0io 28pf+0w

So trial #3 is an anamoly, since it completed quickly
as well.  All the rest of the trials completed very
slowly, in comparison.

Any idea what is going on here?

AFAIK, the test program is in steady state and doesn't
do any I/O.  So its behavior should not be a factor.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
