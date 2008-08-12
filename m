Date: Mon, 11 Aug 2008 21:56:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 1/2] mm owner fix race between swap and exit
Message-Id: <20080811215633.f8f5406d.akpm@linux-foundation.org>
In-Reply-To: <48A10C4C.6020009@linux.vnet.ibm.com>
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
	<20080811100733.26336.31346.sendpatchset@balbir-laptop>
	<20080811173138.71f5bbe4.akpm@linux-foundation.org>
	<48A10C4C.6020009@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Aug 2008 09:36:36 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > This patch applies to mainline, 2.6.27-rc2 and even 2.6.26.
> > 
> > Against which kernel/patch is it actually applicable?
> > 
> > (If the answer was "all of the above" then please don't go embedding
> > mainline bugfixes in the middle of a -mm-only patch series!)
> 
> Andrew,
> 
> The answer is all, but the bug is not exposed *outside* of the memrlimit
> controller, thus the push into -mm. I can redo and rework the patches for
> mainline if required and pull it out of -mm.

OK, I'll move it into the general MM patchpile for 2.6.28.  It will precede
any memrlimit merge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
