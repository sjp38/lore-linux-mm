Date: Fri, 11 Apr 2008 13:58:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v9)
Message-Id: <20080411135810.87536503.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47FEED67.1080006@linux.vnet.ibm.com>
References: <20080410091602.4472.32172.sendpatchset@localhost.localdomain>
	<20080411123339.89aea319.kamezawa.hiroyu@jp.fujitsu.com>
	<47FEE89A.1010102@linux.vnet.ibm.com>
	<20080411134739.1aae8bae.kamezawa.hiroyu@jp.fujitsu.com>
	<47FEED67.1080006@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Apr 2008 10:17:35 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Good question. It is possible that clone() was called with CLONE_VM without
> CLONE_THREAD. In which case we have threads sharing the VM without a thread
> group leader. Please see zap_threads() for a similar search pattern.
> 
Oh. thank you for kindly explanation.

I'll test this on 2.6.25-rc8-mm2.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
