Date: Thu, 10 Jul 2003 06:36:46 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [announce, patch] 4G/4G split on x86, 64 GB RAM (and more) support
Message-ID: <86930000.1057844205@[10.10.2.4]>
In-Reply-To: <80050000.1057800978@[10.10.2.4]>
References: <Pine.LNX.4.44.0307082332450.17252-100000@localhost.localdomain> <80050000.1057800978@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Results now with highpte

2.5.74-bk6-44 is with the patch applied
2.5.74-bk6-44-on is with the patch applied and 4/4 config option.
2.5.74-bk6-44-hi is with the patch applied and with highpte instead.

Overhead of 4/4 isn't much higher, and is much more generally useful.

Kernbench: (make -j vmlinux, maximal tasks)
                              Elapsed      System        User         CPU
                   2.5.74       46.11      115.86      571.77     1491.50
            2.5.74-bk6-44       45.92      115.71      570.35     1494.75
         2.5.74-bk6-44-on       48.11      134.51      583.88     1491.75
         2.5.74-bk6-44-hi       47.06      131.13      570.79     1491.50

SDET 128  (see disclaimer)
                           Throughput    Std. Dev
                   2.5.74       100.0%         0.1%
            2.5.74-bk6-44       100.3%         0.7%
         2.5.74-bk6-44-on        92.1%         0.2%
         2.5.74-bk6-44-hi        94.5%         0.1%


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
