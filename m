Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F0A966B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 03:40:48 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBG8EcRP013390
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 13:44:38 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBG8egqv3637416
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 14:10:43 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBG8efHS019270
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 14:10:42 +0530
Date: Wed, 16 Dec 2009 14:10:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC v2 2/4] memcg: extract mem_group_usage() from
 mem_cgroup_read()
Message-ID: <20091216084037.GA4397@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <cover.1260571675.git.kirill@shutemov.name>
 <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutemov <kirill@shutemov.name> [2009-12-12 00:59:17]:

> Helper to get memory or mem+swap usage of the cgroup.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Looks like a good cleanup to me!

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
