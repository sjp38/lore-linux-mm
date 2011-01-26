Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B89738D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 01:34:40 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p0S6T5e7018777
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:29:05 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0S6YRJf2089072
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:34:27 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0S6YRDs008481
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:34:27 +1100
Date: Wed, 26 Jan 2011 23:13:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] Move zone_reclaim() outside of CONFIG_NUMA (v4)
Message-ID: <20110126174318.GQ2897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110125050255.13141.688.stgit@localhost6.localdomain6>
 <20110125050430.13141.21260.stgit@localhost6.localdomain6>
 <alpine.DEB.2.00.1101261008440.23080@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101261008440.23080@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux.com> [2011-01-26 10:56:56]:

> 
> Reviewed-by: Christoph Lameter <cl@linux.com>
>

Thanks for the review! 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
