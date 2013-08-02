Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 5D5E26B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 03:33:07 -0400 (EDT)
Date: Fri, 2 Aug 2013 09:33:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-ID: <20130802073304.GA17746@dhcp22.suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <51F9D1F6.4080001@jp.fujitsu.com>
 <20130731201708.efa5ae87.akpm@linux-foundation.org>
 <CAHGf_=r7mek+ueJWfu_6giMOueDTnMs8dY1jJrKyX+gfPys6uA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=r7mek+ueJWfu_6giMOueDTnMs8dY1jJrKyX+gfPys6uA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dave.hansen@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu 01-08-13 21:39:48, KOSAKI Motohiro wrote:
> On Wed, Jul 31, 2013 at 11:17 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 31 Jul 2013 23:11:50 -0400 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> >
> >> >> --- a/fs/drop_caches.c
> >> >> +++ b/fs/drop_caches.c
> >> >> @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
> >> >>    if (ret)
> >> >>            return ret;
> >> >>    if (write) {
> >> >> +          printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> >> >> +                 current->comm, task_pid_nr(current), sysctl_drop_caches);
> >> >>            if (sysctl_drop_caches & 1)
> >> >>                    iterate_supers(drop_pagecache_sb, NULL);
> >> >>            if (sysctl_drop_caches & 2)
> >> >
> >> > How about we do
> >> >
> >> >     if (!(sysctl_drop_caches & 4))
> >> >             printk(....)
> >> >
> >> > so people can turn it off if it's causing problems?
> >>
> >> The best interface depends on the purpose. If you want to detect crazy application,
> >> we can't assume an application co-operate us. So, I doubt this works.
> >
> > You missed the "!".  I'm proposing that setting the new bit 2 will
> > permit people to prevent the new printk if it is causing them problems.
> 
> No I don't. I'm sure almost all abuse users think our usage is correct. Then,
> I can imagine all crazy applications start to use this flag eventually.

I guess we do not care about those. If somebody wants to shoot his feet
then we cannot do much about it. The primary motivation was to find out
those that think this is right and they are willing to change the setup
once they know this is not the right way to do things.

I think that giving a way to suppress the warning is a good step. Log
level might be to coarse and sysctl would be an overkill.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
