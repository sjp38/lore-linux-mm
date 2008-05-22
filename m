Date: Wed, 21 May 2008 21:19:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 3/4] cgroup mm owner callback changes to add task
 info (v5)
Message-Id: <20080521211958.ca4f733c.akpm@linux-foundation.org>
In-Reply-To: <20080521152959.15001.14495.sendpatchset@localhost.localdomain>
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>
	<20080521152959.15001.14495.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 20:59:59 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> This patch adds an additional field to the mm_owner callbacks. This field
> is required to get to the mm that changed. Hold mmap_sem in write mode
> before calling the mm_owner_changed callback
>
> ...
>
> + * The callbacks are invoked with mmap_sem held in read mode.

Is that true?

> +	down_write(&mm->mmap_sem);
> ...
>  	cgroup_mm_owner_callbacks(mm->owner, c);

Looks like write-mode to me?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
