Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B6F75F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:30:47 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so1552895wah.22
        for <linux-mm@kvack.org>; Wed, 08 Apr 2009 00:31:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090407063722.GQ7082@balbir.in.ibm.com>
	 <20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090407080355.GS7082@balbir.in.ibm.com>
	 <20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090408052904.GY7082@balbir.in.ibm.com>
	 <20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090408070401.GC7082@balbir.in.ibm.com>
	 <20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090408071115.GD7082@balbir.in.ibm.com>
	 <20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 8 Apr 2009 13:01:15 +0530
Message-ID: <344eb09a0904080031y4406c001n584725b87024755@mail.gmail.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
From: Bharata B Rao <bharata.rao@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 8, 2009 at 12:48 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> On Wed, 8 Apr 2009 12:41:15 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 3. Using the above, we can then try to (using an algorithm you
> > proposed), try to do some work for figuring out the shared percentage.
> >
> This is the point. At last. Why "# of shared pages" is important ?
>
> I wonder it's better to add new stat file as memory.cacheinfo which helps
> following kind of commands.
>
> =A0#cacheinfo /cgroups/memory/group01/
> =A0 =A0 =A0 /usr/lib/libc.so.1 =A0 =A0 30pages
> =A0 =A0 =A0 /var/log/messages =A0 =A0 =A01 pages
> =A0 =A0 =A0 /tmp/xxxxxx =A0 =A0 =A0 =A0 =A0 =A020 pages

Can I suggest that we don't add new files for additional stats and try
as far as possible to include them in <controller>.stat file. Please
note that we have APIs in libcgroup library which can return
statistics from controllers associated with a cgroup and these APIs
assume that stats are part of <controller>.stat file.

Regards,
Bharata.
--
http://bharata.sulekha.com/blog/posts.htm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
