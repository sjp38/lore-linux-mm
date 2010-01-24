Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1536B0047
	for <linux-mm@kvack.org>; Sun, 24 Jan 2010 15:50:44 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0OKobj6027274
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 02:20:37 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0OKoa2a741452
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 02:20:37 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0OKoavv010892
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 02:20:36 +0530
Message-ID: <4B5CB29A.9010804@linux.vnet.ibm.com>
Date: Mon, 25 Jan 2010 02:20:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/memcontrol.c: fix "integer as NULL pointer" warning.
References: <1264349038-1766-1-git-send-email-tfransosi@gmail.com> <1264349038-1766-4-git-send-email-tfransosi@gmail.com>
In-Reply-To: <1264349038-1766-4-git-send-email-tfransosi@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Thiago Farina <tfransosi@gmail.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 24 January 2010 09:33 PM, Thiago Farina wrote:
> mm/memcontrol.c:2548:32: warning: Using plain integer as NULL pointer

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
Three Cheers,
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
