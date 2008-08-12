Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7C576Sh019721
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 15:07:06 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7C550Y02080998
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 15:05:00 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7C550vc030859
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 15:05:00 +1000
Message-ID: <48A119FA.6070105@linux.vnet.ibm.com>
Date: Tue, 12 Aug 2008 10:34:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/2] mm owner fix race between swap and exit
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop> <20080811100733.26336.31346.sendpatchset@balbir-laptop> <20080811173138.71f5bbe4.akpm@linux-foundation.org> <48A10C4C.6020009@linux.vnet.ibm.com> <20080811215633.f8f5406d.akpm@linux-foundation.org>
In-Reply-To: <20080811215633.f8f5406d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> OK, I'll move it into the general MM patchpile for 2.6.28.  It will precede
> any memrlimit merge.

Thanks, sounds good.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
