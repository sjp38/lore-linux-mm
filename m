Date: Wed, 7 May 2008 10:09:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 0/4] Add rlimit controller to cgroups (v3)
Message-Id: <20080507100935.28316ff7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <481E8B3F.3050508@linux.vnet.ibm.com>
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	<23630056.1209914669637.kamezawa.hiroyu@jp.fujitsu.com>
	<481E8B3F.3050508@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 05 May 2008 09:51:19 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 3. Rleated to 2. Showing what kind of "rlimit" params are supported by
> >    cgroup will be good.
> > 
> 
> Do you mean in init/Kconfig or documentation?. I should probably rename
> limit_in_bytes and usage_in_bytes to add an as_ prefix, so that the UI clearly
> shows what is supported as well.
I see.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
