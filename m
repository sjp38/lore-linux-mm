Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D6C46B0078
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 22:17:22 -0500 (EST)
Message-ID: <4B8348C8.4050605@cn.fujitsu.com>
Date: Tue, 23 Feb 2010 11:17:28 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 -mmotm 1/4] cgroups: Fix race between userspace and
 kernelspace
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
In-Reply-To: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

(Late reply for I just came back from a long vacation)

Kirill A. Shutemov wrote:
> eventfd are used to notify about two types of event:
>  - control file-specific, like crossing memory threshold;
>  - cgroup removing.
> 
> To understand what really happen, userspace can check if the cgroup
> still exists. To avoid race beetween userspace and kernelspace we have
> to notify userspace about cgroup removing only after rmdir of cgroup
> directory.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
