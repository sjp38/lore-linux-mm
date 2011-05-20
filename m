Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 987608D003B
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:12:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DE3EF3EE0C3
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:12:17 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C635345DE96
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:12:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9838F45DE94
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:12:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 884BB1DB8037
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:12:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 518CEE08002
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:12:17 +0900 (JST)
Message-ID: <4DD5DC06.6010204@jp.fujitsu.com>
Date: Fri, 20 May 2011 12:12:06 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com> <20110512054631.GI6008@one.firstfloor.org> <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com> <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com> <20110514165346.GV6008@one.firstfloor.org> <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com> <20110514174333.GW6008@one.firstfloor.org> <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com> <20110515152747.GA25905@localhost> <BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com> <20110517060001.GC24069@localhost> <BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com> <BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com> <BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com> <BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com> <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com> <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
In-Reply-To: <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: luto@mit.edu
Cc: minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

> Right after that happened, I hit ctrl-c to kill test_mempressure.sh.
> The system was OK until I typed sync, and then everything hung.
>
> I'm really confused.  shrink_inactive_list in
> RECLAIM_MODE_LUMPYRECLAIM will call one of the isolate_pages functions
> with ISOLATE_BOTH.  The resulting list goes into shrink_page_list,
> which does VM_BUG_ON(PageActive(page)).
>
> How is that supposed to work?

Usually clear_active_flags() clear PG_active before calling shrink_page_list().

shrink_inactive_list()
     isolate_pages_global()
     update_isolated_counts()
         clear_active_flags()
     shrink_page_list()



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
