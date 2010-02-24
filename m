Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B6606B007B
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:30:15 -0500 (EST)
Message-ID: <4B849D4C.2090800@cn.fujitsu.com>
Date: Wed, 24 Feb 2010 11:30:20 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 -mmotm 3/4] cgroups: Add simple listener of cgroup
 events to documentation
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name> <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name> <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
In-Reply-To: <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> +	ret = dprintf(event_control, "%d %d %s", efd, cfd, argv[2]);

I found it won't return negative value for invalid input, though
errno is set properly.

try:
# ./cgroup_event_listner /cgroup/cgroup.procs abc

while strace shows write() does return -1:

# strace ./cgroup_event_listner /cgroup/cgroup.procs abc
...
write(6, "7 5 abc"..., 7)               = -1 EINVAL (Invalid argument)

> +	if (ret == -1) {
> +		perror("Cannot write to cgroup.event_control");
> +		goto out;
> +	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
