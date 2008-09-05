Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m85G3opI014098
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 17:03:51 +0100
Received: from gxk14 (gxk14.prod.google.com [10.202.11.14])
	by zps76.corp.google.com with ESMTP id m85Fwr0X021386
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 09:03:50 -0700
Received: by gxk14 with SMTP id 14so7064339gxk.20
        for <linux-mm@kvack.org>; Fri, 05 Sep 2008 09:03:49 -0700 (PDT)
Message-ID: <6599ad830809050903s7e1a1004i6b31660502c0dcf2@mail.gmail.com>
Date: Fri, 5 Sep 2008 09:03:49 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH][mmotm]memcg: handle null dereference of mm->owner
In-Reply-To: <20080905174021.9fa29b01.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080905165017.b2715fe4.nishimura@mxp.nes.nec.co.jp>
	 <20080905174021.9fa29b01.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 5, 2008 at 1:40 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> BTW, I have a question to Balbir and Paul. (I'm sorry I missed the discussion.)
> Recently I wonder why we need MM_OWNER.
>
> - What's bad with thread's cgroup ?

Because lots of mm operations take place in a context where we don't
have a thread pointer, and hence no cgroup.

> - Why we can't disallow per-thread cgroup under memcg ?)

We can, but that's orthogonal - we still need to be able to get to
some thread (or a pointer directly in the mm to the cgroup, but with
multiple cgroup subsystems popping up that needed such a pointer, it
seems cleaner to have the owner pointer rather than adding multiple
separate cgroup subsystem pointers to mm.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
