Date: Mon, 5 May 2008 15:24:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
Message-Id: <20080505152451.6dceec74.akpm@linux-foundation.org>
In-Reply-To: <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	<20080503213814.3140.66080.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sun, 04 May 2008 03:08:14 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +	if (res_counter_charge(&rcg->as_res, (mm->total_vm << PAGE_SHIFT)))

I worry a bit about all the conversion between page-counts and byte-counts
in this code.

For example, what happens if a process sits there increasing its rss with
sbrk(4095) or sbrk(4097) or all sorts of other scenarios?  Do we get in a
situation in which the accounting is systematically wrong?

Worse, do we risk getting into that situation in the future, as unrelated
changes are made to the surrounding code?

IOW, have we chosen the best, most maintainable representation for these
things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
