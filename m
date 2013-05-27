Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 5A8AB6B00F1
	for <linux-mm@kvack.org>; Mon, 27 May 2013 02:48:31 -0400 (EDT)
Date: Mon, 27 May 2013 08:48:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] mm/memory_hotplug: Disable memory hotremove for
 32bit
Message-ID: <20130527064808.GA27274@dhcp22.suse.cz>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369547921-24264-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130526090054.GE10651@dhcp22.suse.cz>
 <20130526090617.GA28604@hacker.(null)>
 <20130526181209.GB20270@dhcp22.suse.cz>
 <20130526235138.GA3223@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130526235138.GA3223@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Mon 27-05-13 07:51:38, Wanpeng Li wrote:
> On Sun, May 26, 2013 at 08:12:09PM +0200, Michal Hocko wrote:
> >On Sun 26-05-13 17:06:17, Wanpeng Li wrote:
> >> On Sun, May 26, 2013 at 11:00:54AM +0200, Michal Hocko wrote:
> >> >On Sun 26-05-13 13:58:38, Wanpeng Li wrote:
> >> >> As KOSAKI Motohiro mentioned, memory hotplug don't support 32bit since 
> >> >> it was born, 
> >> >
> >> >Why? any reference? This reasoning is really weak.
> >> >
> >> 
> >> http://marc.info/?l=linux-mm&m=136953099010171&w=2
> >
> >I have seen the email but that email just states that the feature is
> >broken. Maybe it is obvious to you _what_ is actually broken but it
> >doesn't need to be others especially those who would be reading such
> >changelog later. So if you consider this configuration broken then be
> >specific what is broken.
> >
> 
> Sorry for the not enough information. KOSAKI explain more here:
> http://marc.info/?l=linux-mm&m=136958040921274&w=2 

There are still just general claims that _something_ is not highmem
aware.

Anyway, as it seems that there are some attempts to revive this code
then this discussion is moot. But, just for the future, make sure you
are really specific when you claim that something is broken. Somebody
said it was broken is _not_ a reasoning that would fly.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
