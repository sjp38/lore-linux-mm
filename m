Date: Fri, 7 Mar 2008 01:06:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Make memory resource control aware of boot options (v2)
Message-Id: <20080307010649.74f51535.akpm@linux-foundation.org>
In-Reply-To: <20080307085746.25567.71595.sendpatchset@localhost.localdomain>
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain>
	<20080307085746.25567.71595.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 07 Mar 2008 14:27:46 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +	if (mem_cgroup_subsys.disabled)

My copy of `struct cgroup_subsys' doesn't have a .disabled?

If it did, I might want it __read_mostly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
