Date: Wed, 10 Oct 2007 09:34:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [1/6]
 fix refcnt race in charge/uncharge
Message-Id: <20071010093442.7ade1b8d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071009223139.061C21BF47A@siro.lan>
References: <20071009184925.ad8248d4.kamezawa.hiroyu@jp.fujitsu.com>
	<20071009223139.061C21BF47A@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: containers@lists.osdl.org, linux-mm@kvack.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 10 Oct 2007 07:31:38 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> > -		atomic_inc(&pc->ref_cnt);
> > -		goto done;
> > +		if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
> > +			/* this page is under being uncharge ? */
> > +			unlock_page_cgroup(page);
> 
> cpu_relax() here?
> 
Ah, yes. there should be. I'll add.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
