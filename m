Subject: md hangs while rebuilding
From: "Shesha B. " Sreenivasamurthy <shesha@inostor.com>
Content-Type: text/plain
Message-Id: <1096658210.9342.1525.camel@arcane>
Mime-Version: 1.0
Date: 01 Oct 2004 12:16:51 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hello All,

I have 9 disks raid 1. I pulled out 4 disks, and using raidhotadd I
triggered a rebuild on 3 of them. While rebuilding md1, the rebuilding
process is stuck at 0.0%. Below is a snapshot of "/proc/mdstat". 

-----
md1 : active raid1 sdi2[12] sdh2[11] sdg2[10] sde2[4] sdd2[1] sdc2[0]
sdb2[2] sda2[5]
      405504 blocks [9/5] [UUU_UU___]
      [>....................]  recovery =  0.0% (384/405504)
finish=176649.2min speed=0K/sec
-----

The finish="***" time is increasing constantly.

(1) What may be the cause. I have experienced it several times. There is
no heavy IO going-on on any of the partitions. Machine is kind of idle.
(2) Can we somehow stop the rebuilding process and restart it again?
(3) Rebooting will fix it. But I am trying to find a better solution.

Any help is highly appreciated.

Thanking You
Shesha

-- 
  .-----.
 /       \
{  o | o  } 
     |
    \_/
      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
