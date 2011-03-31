Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 265608D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 01:27:14 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2V5R72P001900
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:57:07 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2V5R7FM3735686
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:57:07 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2V5R8nn004179
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:57:08 +0530
Date: Thu, 31 Mar 2011 10:57:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
Message-ID: <20110331052703.GJ2879@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
 <20110330163607.0984b831.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110330163607.0984b831.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

* Andrew Morton <akpm@linux-foundation.org> [2011-03-30 16:36:07]:

> On Wed, 30 Mar 2011 11:00:26 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Data from the previous patchsets can be found at
> > https://lkml.org/lkml/2010/11/30/79
> 
> It would be nice if the data for the current patchset was present in
> the current patchset's changelog!
>

Sure, since there were no major changes, I put in a URL. The main
change was the documentation update. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
