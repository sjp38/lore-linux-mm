Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 652B86B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:40:09 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id wd6so148501obb.33
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 18:40:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130731201708.efa5ae87.akpm@linux-foundation.org>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <51F9D1F6.4080001@jp.fujitsu.com> <20130731201708.efa5ae87.akpm@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 1 Aug 2013 21:39:48 -0400
Message-ID: <CAHGf_=r7mek+ueJWfu_6giMOueDTnMs8dY1jJrKyX+gfPys6uA@mail.gmail.com>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info message
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dave.hansen@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Wed, Jul 31, 2013 at 11:17 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 31 Jul 2013 23:11:50 -0400 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> >> --- a/fs/drop_caches.c
>> >> +++ b/fs/drop_caches.c
>> >> @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
>> >>    if (ret)
>> >>            return ret;
>> >>    if (write) {
>> >> +          printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
>> >> +                 current->comm, task_pid_nr(current), sysctl_drop_caches);
>> >>            if (sysctl_drop_caches & 1)
>> >>                    iterate_supers(drop_pagecache_sb, NULL);
>> >>            if (sysctl_drop_caches & 2)
>> >
>> > How about we do
>> >
>> >     if (!(sysctl_drop_caches & 4))
>> >             printk(....)
>> >
>> > so people can turn it off if it's causing problems?
>>
>> The best interface depends on the purpose. If you want to detect crazy application,
>> we can't assume an application co-operate us. So, I doubt this works.
>
> You missed the "!".  I'm proposing that setting the new bit 2 will
> permit people to prevent the new printk if it is causing them problems.

No I don't. I'm sure almost all abuse users think our usage is correct. Then,
I can imagine all crazy applications start to use this flag eventually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
