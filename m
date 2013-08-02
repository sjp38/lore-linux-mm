Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id CFCED6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:04:08 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id m1so1715837oag.32
        for <linux-mm@kvack.org>; Fri, 02 Aug 2013 09:04:08 -0700 (PDT)
Date: Fri, 02 Aug 2013 11:04:02 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
In-Reply-To: <20130731201708.efa5ae87.akpm@linux-foundation.org> (from
	akpm@linux-foundation.org on Wed Jul 31 22:17:08 2013)
Message-Id: <1375459442.8422.1@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, dave@linux.vnet.ibm.com

On 07/31/2013 10:17:08 PM, Andrew Morton wrote:
> On Wed, 31 Jul 2013 23:11:50 -0400 KOSAKI Motohiro =20
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>=20
> > >> --- a/fs/drop_caches.c
> > >> +++ b/fs/drop_caches.c
> > >> @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table =20
> *table, int write,
> > >>  	if (ret)
> > >>  		return ret;
> > >>  	if (write) {
> > >> +		printk(KERN_INFO "%s (%d): dropped kernel =20
> caches: %d\n",
> > >> +		       current->comm, task_pid_nr(current), =20
> sysctl_drop_caches);
> > >>  		if (sysctl_drop_caches & 1)
> > >>  			iterate_supers(drop_pagecache_sb, NULL);
> > >>  		if (sysctl_drop_caches & 2)
> > >
> > > How about we do
> > >
> > > 	if (!(sysctl_drop_caches & 4))
> > > 		printk(....)
> > >
> > > so people can turn it off if it's causing problems?
> >
> > The best interface depends on the purpose. If you want to detect =20
> crazy application,
> > we can't assume an application co-operate us. So, I doubt this =20
> works.
>=20
> You missed the "!".  I'm proposing that setting the new bit 2 will
> permit people to prevent the new printk if it is causing them =20
> problems.

Or an alternative for those planning to patch it down to a KERN_DEBUG =20
locally.

I'd be surprised if anybody who does this sees the printk and thinks =20
"hey, I'll dig into the VM's balancing logic and come up to speed on =20
the tradeoffs sufficient to contribute to kernel development" because =20
of something in dmesg. Anybody actually annoyed by it will chop out the =20
printk (you barely need to know C to do that), the rest won't notice.

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
