Date: Wed, 25 Jun 2008 16:41:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2/2] memrlimit fix usage of tmp as a parameter name
Message-Id: <20080625164121.9146fb56.akpm@linux-foundation.org>
In-Reply-To: <20080620150152.16094.76790.sendpatchset@localhost.localdomain>
References: <20080620150132.16094.29151.sendpatchset@localhost.localdomain>
	<20080620150152.16094.76790.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 20 Jun 2008 20:31:52 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Fix the variable tmp being used in write_strategy. This patch replaces tmp
> with val, the fact that it is an output parameter can be interpreted from
> the pass by reference.

Paul's "CGroup Files: Convert res_counter_write() to be a cgroups
write_string() handler"
(memrlimit-setup-the-memrlimit-controller-cgroup-files-convert-res_counter_write-to-be-a-cgroups-write_string-handler-memrlimitcgroup.patch)
deleted memrlimit_cgroup_write_strategy(), so problem solved ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
