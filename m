Date: Fri, 6 Jun 2008 10:55:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: clean up checking of  the disabled flag
Message-Id: <20080606105535.de04c038.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4848955D.2020302@cn.fujitsu.com>
References: <4848955D.2020302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 06 Jun 2008 09:39:41 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Those checks are unnecessary, because when the subsystem is disabled
> it can't be mounted, so those functions won't get called.
> 
> The check is needed in functions which will be called in other places
> except cgroup.
> 
Good catch!

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
