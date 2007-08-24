Subject: Re: [PATCH] Memory controller Add Documentation
In-Reply-To: Your message of "Wed, 22 Aug 2007 18:36:12 +0530"
	<20070822130612.18981.58696.sendpatchset@balbir-laptop>
References: <20070822130612.18981.58696.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070824084816.4F23E1BFA1D@siro.lan>
Date: Fri, 24 Aug 2007 17:48:15 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, npiggin@suse.de, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> +echo 1 > /proc/sys/vm/drop_pages will help get rid of some of the pages
> +cached in the container (page cache pages).

drop_caches

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
