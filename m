Date: Thu, 19 Jun 2008 18:38:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 0/5] memory related bugfix set for 2.6.26-rc5-mm3 
In-Reply-To: <20080619172241.E7FC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080619172241.E7FC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080619183230.E814.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew,

the mailing list manager of linux-mm dropped "From:" line 
at beginning of the mail ;)

the patches are writed by below person.
please pay attention.

1/5 fix munlock page table walk
	-> From: Lee Schermerhorn <lee.schermerhorn@hp.com>
2/5 migration_entry_wait fix.
	-> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
3/5 collect lru meminfo statistics from correct offset
	-> From: Lee Schermerhorn <lee.schermerhorn@hp.com>
4/5 fix incorrect Mlocked field of /proc/meminfo.
	-> Hugh Dickins <hugh@veritas.com>
5/5 putback_lru_page()/unevictable page handling rework
	-> From: KAMEZAWA Hiroyuki <kamezawa.hiroy@jp.fujitsu.com>



> Hi, Andrew and -mm guys!
> 
> Unfortunately, linux-2.6.26-rc5-mm3 has several bugs and 
> some bugs depend on each other.
> 
> thus, I collect, sort, and fold these patchs..
> this patchset surve on my stress workload >5H.
> 
> enjoy!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
