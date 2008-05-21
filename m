Date: Wed, 21 May 2008 22:08:33 +0900 (JST)
Message-Id: <20080521.220833.106490043.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH 2/3] memcg:: seq_ops support for cgroup
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <6599ad830805202206v334cb933t5b493988e01b3b21@mail.gmail.com>
References: <6599ad830805201146g5a2a8928l6a2f5adc51b15f15@mail.gmail.com>
	<20080521092849.c2f0b7e1.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830805202206v334cb933t5b493988e01b3b21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

Hi,

> > With current interface, my concern is hotplug.
> >
> > File-per-node method requires delete/add files at hotplug.
> > A file for all nodes with _maps_ method cannot be used because
> > maps file says
> > ==
> > The key/value pairs (and their ordering) should not
> >         * change between reboots.
> > ==
> 
> OK, so we may need to extend the interface ...

I also hope it!

Now I'm working on dm-ioband --- I/O bandwidth controller --- and
making it be able to work under cgroups.
I realized it is quite hard to set some specific value to each block
device because each machine has various number of devices and then
some of them are hot-added or hot-removed.

So I hope CGROUP will support some method to handle hot-pluggable
resources.

> The main reason for that restriction (not allowing the set of keys to
> change) was to simplify and speed up userspace parsing and make any
> future binary API simpler. But if it's not going to work, we can maybe
> make that optional instead.
> >
> > And (*read) method isn't useful ;)
> >
> > Can we add new stat file dynamically ?
> 
> Yes, there's no reason we can't do that. Right now it's not possible
> to remove a control file without deleting the cgroup, but I have a
> patch that supports removal.
> 
> The question is whether it's better to have one file per CPU/node or
> one large complex file.
> 
> Paul
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
