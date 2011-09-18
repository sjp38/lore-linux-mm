Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F1699000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 15:05:10 -0400 (EDT)
Date: Sun, 18 Sep 2011 22:05:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 1/7] Basic kernel memory functionality for the Memory
 Controller
Message-ID: <20110918190509.GC28057@shutemov.name>
References: <1316051175-17780-1-git-send-email-glommer@parallels.com>
 <1316051175-17780-2-git-send-email-glommer@parallels.com>
 <20110917174535.GA1658@shutemov.name>
 <4E7567E0.9010401@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E7567E0.9010401@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 18, 2011 at 12:39:12AM -0300, Glauber Costa wrote:
> > No kernel memory accounting for root cgroup, right?
> Not sure. Maybe kernel memory accounting is useful even for root cgroup. 
> Same as normal memory accounting... what we want to avoid is kernel 
> memory limits. OTOH, if we are not limiting it anyway, accounting it is 
> just useless overhead... Even the statistics can then be gathered 
> through all
> the proc files that show slab usage, I guess?

It's better to leave root cgroup without accounting. At least for now.
We can add it later if needed.

> >
> >> @@ -3979,6 +3999,10 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
> >>   		else
> >>   			val = res_counter_read_u64(&mem->memsw, name);
> >>   		break;
> >> +	case _KMEM:
> >> +		val = res_counter_read_u64(&mem->kmem, name);
> >> +		break;
> >> +
> >
> > Always zero in root cgroup?
> 
> Yes, if we're not accounting, it should be zero. WARN_ON, maybe?

-ENOSYS?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
