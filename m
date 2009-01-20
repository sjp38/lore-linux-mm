Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 11F466B0083
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:55:43 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n0K1teri027171
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 01:55:40 GMT
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by spaceape14.eur.corp.google.com with ESMTP id n0K1tZl3005566
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:55:36 -0800
Received: by rv-out-0708.google.com with SMTP id f25so3172461rvb.14
        for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:55:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <49752E11.20209@cn.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090116120001.f37e1895.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901191741j4668f529s97ee6e896b0c011d@mail.gmail.com>
	 <49752E11.20209@cn.fujitsu.com>
Date: Mon, 19 Jan 2009 17:55:34 -0800
Message-ID: <6599ad830901191755r52c3bd23v33a28dc8b9896916@mail.gmail.com>
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 19, 2009 at 5:51 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> Yes, but I can see a potential problem. If we have subsystem foo and bar,
> and both of them have a control file with exactly the same name, like
> foo.stat & bar.stat. Now we mount them with -o noprefix, and then one
> of the stat file will fail to be created, without any warnning or notification
> to the user.

That's a fair point. The "noprefix" option was really only added for
backwards-compatibility when mounting as the "cpuset" filesystem type,
so it shouldn't end up getting used directly. But you're right that
this does mean that populate can fail and we should handle that, or
else make the "noprefix" option only usable from within the kernel
when mounting cpusets.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
