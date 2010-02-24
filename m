Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 87AE06B0078
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 06:42:17 -0500 (EST)
Received: by wwb24 with SMTP id 24so1108265wwb.14
        for <linux-mm@kvack.org>; Wed, 24 Feb 2010 03:42:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100224084005.GC2310@balbir.in.ibm.com>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
	 <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
	 <20100224084005.GC2310@balbir.in.ibm.com>
Date: Wed, 24 Feb 2010 13:42:15 +0200
Message-ID: <cc557aab1002240342u1b0223a4td8269d727b004621@mail.gmail.com>
Subject: Re: [PATCH v2 -mmotm 2/4] cgroups: remove events before destroying
	subsystem state objects
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 10:40 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
> * Kirill A. Shutemov <kirill@shutemov.name> [2010-02-22 17:43:40]:
>
>> Events should be removed after rmdir of cgroup directory, but before
>> destroying subsystem state objects. Let's take reference to cgroup
>> directory dentry to do that.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
>
> Looks good, but remember the mem_cgroup data structure will can
> disappear after the rmdir

IIUC, struct mem_cgroup can be freed only after ->destroy(), which can
be called only if there is no references to cgroup directory dentry.

Have I missed something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
