Received: by an-out-0708.google.com with SMTP id d17so387461and.105
        for <linux-mm@kvack.org>; Mon, 04 Aug 2008 07:36:25 -0700 (PDT)
Message-ID: <28c262360808040736u7f364fc0p28d7ceea7303a626@mail.gmail.com>
Date: Mon, 4 Aug 2008 23:36:25 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Race condition between putback_lru_page and mem_cgroup_move_list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I think this is a race condition if mem_cgroup_move_lists's comment isn't right.
I am not sure that it was already known problem.

mem_cgroup_move_lists assume the appropriate zone's lru lock is already held.
but putback_lru_page calls mem_cgroup_move_lists without holding lru_lock.

Repeatedly, spin_[un/lock]_irq use in mem_cgroup_move_list have a big overhead
while doing list iteration.

Do we have to use pagevec ?

-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
