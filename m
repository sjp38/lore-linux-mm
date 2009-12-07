Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88CAA60021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 03:05:11 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id nB7J58TJ004253
	for <linux-mm@kvack.org>; Tue, 8 Dec 2009 06:05:08 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB781O6o1638622
	for <linux-mm@kvack.org>; Mon, 7 Dec 2009 19:01:25 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB7856YN031414
	for <linux-mm@kvack.org>; Mon, 7 Dec 2009 19:05:06 +1100
Date: Mon, 7 Dec 2009 13:35:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: code clean,rm unused variable in
 mem_cgroup_resize_limit
Message-ID: <20091207080503.GG5780@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <cf18f8340912061837j16c9aa25vc6af8a4a1fce989c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <cf18f8340912061837j16c9aa25vc6af8a4a1fce989c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

* Bob Liu <lliubbo@gmail.com> [2009-12-07 10:37:24]:

> Variable progress isn't used in funtion mem_cgroup_resize_limit anymore.
> Remove it.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Good catch! Please run checkpatch.pl before submitting with the
changes recommended by Daisuke-San.

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
