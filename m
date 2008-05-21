Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id m4L56nYD002011
	for <linux-mm@kvack.org>; Wed, 21 May 2008 06:06:50 +0100
Received: from an-out-0708.google.com (ancc35.prod.google.com [10.100.29.35])
	by spaceape7.eur.corp.google.com with ESMTP id m4L56mDZ014412
	for <linux-mm@kvack.org>; Wed, 21 May 2008 06:06:49 +0100
Received: by an-out-0708.google.com with SMTP id c35so647088anc.119
        for <linux-mm@kvack.org>; Tue, 20 May 2008 22:06:48 -0700 (PDT)
Message-ID: <6599ad830805202206v334cb933t5b493988e01b3b21@mail.gmail.com>
Date: Tue, 20 May 2008 22:06:48 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 2/3] memcg:: seq_ops support for cgroup
In-Reply-To: <20080521092849.c2f0b7e1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080520180841.f292beef.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830805201146g5a2a8928l6a2f5adc51b15f15@mail.gmail.com>
	 <20080521092849.c2f0b7e1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 5:28 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> With current interface, my concern is hotplug.
>
> File-per-node method requires delete/add files at hotplug.
> A file for all nodes with _maps_ method cannot be used because
> maps file says
> ==
> The key/value pairs (and their ordering) should not
>         * change between reboots.
> ==

OK, so we may need to extend the interface ...

The main reason for that restriction (not allowing the set of keys to
change) was to simplify and speed up userspace parsing and make any
future binary API simpler. But if it's not going to work, we can maybe
make that optional instead.

>
> And (*read) method isn't useful ;)
>
> Can we add new stat file dynamically ?

Yes, there's no reason we can't do that. Right now it's not possible
to remove a control file without deleting the cgroup, but I have a
patch that supports removal.

The question is whether it's better to have one file per CPU/node or
one large complex file.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
