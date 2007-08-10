Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7A4pxMB4718640
	for <linux-mm@kvack.org>; Fri, 10 Aug 2007 14:51:59 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7A4rR3s078442
	for <linux-mm@kvack.org>; Fri, 10 Aug 2007 14:53:27 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7A4nriq030720
	for <linux-mm@kvack.org>; Fri, 10 Aug 2007 14:49:54 +1000
Message-ID: <46BBEE6D.1040704@linux.vnet.ibm.com>
Date: Fri, 10 Aug 2007 10:19:49 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [-mm PATCH 0/9] Memory controller introduction (v4)
References: <20070727200937.31565.78623.sendpatchset@balbir-laptop> <20070808125139.7cfe702c.kamezawa.hiroyu@jp.fujitsu.com> <20070808165131.b4ab4e92.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070808165131.b4ab4e92.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 8 Aug 2007 12:51:39 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> On Sat, 28 Jul 2007 01:39:37 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> At OLS, the resource management BOF, it was discussed that we need to manage
>>> RSS and unmapped page cache together. This patchset is a step towards that
>>>
>> Can I make a question ? Why limiting RSS instead of # of used pages per
>> container ? Maybe bacause of shared pages between container.... 
> Sorry....Ignore above question.
> I didn't understand what mem_container_charge() accounts and limits.
> It controls # of meta_pages.

Hi Kame,

Actually the number of pages resident in memory brought in by a
container is charged.  However each such page will have a meta_page
allocated to keep the extra data.

Yes, the accounting counts the number of meta_page which is same as
the number of mapped and unmapped (pagecache) pages brought into the
system memory by this container.  Whether pagecache pages should be
included or not is configurable per container through the 'type' file
in containerfs.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
