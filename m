Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C554B6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:52:41 -0400 (EDT)
Date: Thu, 2 Jun 2011 16:52:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Patch] mm: remove the leftovers of noswapaccount
Message-ID: <20110602145239.GC6820@tiehla.suse.cz>
References: <BANLkTinLvqa0DiayLOwvxE9zBmqb4Y7Rww@mail.gmail.com> <20110523112558.GC11439@tiehlicka.suse.cz> <BANLkTi=2SwKFfwBxrQr3xLYSUzoGOy6oKA@mail.gmail.com> <20110530094337.GF20166@tiehlicka.suse.cz> <20110602141622.GA4416@cr0.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110602141622.GA4416@cr0.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu 02-06-11 22:16:22, Americo Wang wrote:
> 
> In commit a2c8990aed5ab (memsw: remove noswapaccount kernel parameter),
> Michal forgot to remove some left pieces of noswapaccount in the tree,
> this patch removes them all.
> 
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
