Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 57E2F6B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 06:22:59 -0500 (EST)
Date: Thu, 7 Jan 2010 20:23:35 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: How should we handle CONFIG_CGROUP_MEM_RES_CTRL_SWAP (Re: [PATCH
 -mmotm] build fix for memcg-move-charges-of-anonymous-swap.patch)
Message-Id: <20100107202335.c18b728b.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100107145223.a73e2be9.kamezawa.hiroyu@jp.fujitsu.com>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
	<20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
	<20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107130609.31fe83dc.nishimura@mxp.nes.nec.co.jp>
	<20100107133026.6350bd9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107141401.6a182085.nishimura@mxp.nes.nec.co.jp>
	<20100107145223.a73e2be9.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Changed the subject and Cc list)

On Thu, 7 Jan 2010 14:52:23 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> BTW, maybe it's time to
>   - remove EXPERIMENTAL from CONFIG_CGROUP_MEM_RES_CTRL_SWAP
> and more,
>   - remove CONFIG_CGROUP_MEM_RES_CTRL_SWAP
>     (to reduce complicated #ifdefs and replace them with CONFIG_SWAP.)
> 
> It's very stable as far as I test.
> 
I agree on both.

Balbir-san, What do you think ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
