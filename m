Date: Sun, 04 May 2008 23:38:43 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 0/5] mm: page reclaim throttle v6
In-Reply-To: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080504232854.8F69.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

page reclaim throttle + split lru series performance is below.
I think its combination is best.


    num_group       vanilla      with throttle     throttle + split lru
   -----------------------------------------------------------------
      80              26.22           24.97           23.75
      85              27.31           25.94           27.01
      90              29.23           26.77           26.90
      95              30.73           28.40           28.81
     100              32.02           30.62           29.18
     105              33.97           31.93           32.21
     110              35.37           33.19           33.10
     115              36.96           33.68           33.90
     120              74.05           36.25           36.58
     125              41.07           39.30           36.64
     130              86.92           45.74           40.55
     135             234.62           45.99           47.18
     140             291.95           57.82           58.91
     145             425.35           70.31           50.63
     150             766.92          113.28          105.33



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
