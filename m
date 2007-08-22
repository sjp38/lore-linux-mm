Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7MHSuSU028154
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 03:28:56 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MHSrsm3563712
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 03:28:53 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MISqa7031084
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 04:28:52 +1000
Message-ID: <46CC724A.7020305@linux.vnet.ibm.com>
Date: Wed, 22 Aug 2007 22:58:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Memory controller Add Documentation
References: <20070822130612.18981.58696.sendpatchset@balbir-laptop> <20070822094633.733614c5.randy.dunlap@oracle.com>
In-Reply-To: <20070822094633.733614c5.randy.dunlap@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

Randy Dunlap wrote:
> On Wed, 22 Aug 2007 18:36:12 +0530 Balbir Singh wrote:
> 
>>  Documentation/memcontrol.txt |  193 +++++++++++++++++++++++++++++++++++++++++++
> 
> Is there some sub-dir that is appropriate for this, such as
> vm/ or accounting/ or containers/ (new) ?
> 
> 

<snip>

Hi, Randy,

Thanks for the detailed review. Most of the comments seem valid,
I will fix them in the next release.

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
