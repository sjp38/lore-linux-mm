Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E677A6B007D
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 22:18:07 -0500 (EST)
Message-ID: <4B8348F6.6030709@cn.fujitsu.com>
Date: Tue, 23 Feb 2010 11:18:14 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 -mmotm 2/4] cgroups: remove events before destroying
 subsystem state objects
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name> <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
In-Reply-To: <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Kirill A. Shutemov wrote:
> Events should be removed after rmdir of cgroup directory, but before
> destroying subsystem state objects. Let's take reference to cgroup
> directory dentry to do that.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>

Looks good.

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
