Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14E666B0217
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 02:49:01 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id o3D6muPA006483
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:48:56 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3D6muek1802250
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:48:56 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3D6muUC003659
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:48:56 +1000
Date: Tue, 13 Apr 2010 12:18:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: update documentation v5
Message-ID: <20100413064855.GH3994@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
 <20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com>
 <20100409100430.7409c7c4.randy.dunlap@oracle.com>
 <20100413134553.7e2c4d3d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100413060405.GF3994@balbir.in.ibm.com>
 <20100413152048.55408738.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100413152048.55408738.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-04-13 15:20:48]:

[snip]

The alignment does not show up in the patches, hence the comments

> > Do we need the <> around memory.usage_in_bytes
> > 
> 
> Hmm ? I'm not sure. 
> 
> Could you explain why you think removing <> is better ?
>

Because it is an actual name as compared to using <> for to be
replaced with the right thing. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
