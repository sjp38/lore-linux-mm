Date: Mon, 5 May 2008 15:11:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 1/4] Setup the rlimit controller
Message-Id: <20080505151142.f52b9d9e.akpm@linux-foundation.org>
In-Reply-To: <20080503213736.3140.83278.sendpatchset@localhost.localdomain>
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	<20080503213736.3140.83278.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sun, 04 May 2008 03:07:36 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +	*tmp = ((*tmp + PAGE_SIZE) >> PAGE_SHIFT) << PAGE_SHIFT;

Whatever this is doing, it should not be doing it this way ;)

perhaps

	*tmp = ALIGN(*tmp, PAGE_SIZE);

or even

	*tmp = PAGE_ALIGN(*tmp);

?


<looks at PAGE_ALIGN>

Each architecture implements its own version and they of course do it
differently.  It's crying out for a consolidated implementation but we have
no include/linux/page.h into which to consolidate it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
