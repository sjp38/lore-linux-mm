Date: Wed, 21 May 2008 21:18:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
Message-Id: <20080521211833.bc7c5255.akpm@linux-foundation.org>
In-Reply-To: <20080521152948.15001.39361.sendpatchset@localhost.localdomain>
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>
	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 20:59:48 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *tmp)

grumble.  I think I requested a checkpatch warning whenever it comes
across "tmp" or "temp".  Even better would be a gcc coredump.

I'm sure there's something more meaningful we could use here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
