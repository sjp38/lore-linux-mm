Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0EB6B00EB
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 00:15:33 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p0P4PdgO010539
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 09:55:39 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0P5FSFv3371050
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 10:45:28 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0P5FSj3014338
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 10:45:28 +0530
Date: Tue, 25 Jan 2011 10:45:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] Refactor zone_reclaim code (v4)
Message-ID: <20110125051512.GO2897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2011-01-25 10:40:09]:

> Changelog v3
> 1. Renamed zone_reclaim_unmapped_pages to zone_reclaim_pages
> 
> Refactor zone_reclaim, move reusable functionality outside
> of zone_reclaim. Make zone_reclaim_unmapped_pages modular
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Reviewed-by: Christoph Lameter <cl@linux.com>

I got the patch numbering wrong due to a internet connection going down
in the middle of stg mail, restarting with specified patches goofed up
the numbering. I can resend the patches with the correct numbering if
desired. This patch should be numbered 2/3

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
