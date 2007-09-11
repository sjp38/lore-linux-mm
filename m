Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8B2e4HO016940
	for <linux-mm@kvack.org>; Tue, 11 Sep 2007 12:40:04 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8B2e3ZM4477158
	for <linux-mm@kvack.org>; Tue, 11 Sep 2007 12:40:03 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8B3e2mM004759
	for <linux-mm@kvack.org>; Tue, 11 Sep 2007 13:40:02 +1000
Message-ID: <46E5FFFB.8020805@linux.vnet.ibm.com>
Date: Tue, 11 Sep 2007 08:09:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH] memory controller statistics
References: <20070907033942.4A6541BFA52@siro.lan> <46E12020.1060203@linux.vnet.ibm.com> <6599ad830709101621r2f1763cfpa0924f884d0ee2c@mail.gmail.com>
In-Reply-To: <6599ad830709101621r2f1763cfpa0924f884d0ee2c@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, svaidy@linux.vnet.ibm.com, containers@lists.osdl.org, minoura@valinux.co.jp, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 9/7/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Thanks for doing this. We are building containerstats for
>> per container statistics. It would be really nice to provide
>> the statistics using that interface. I am not opposed to
>> memory.stat, but Paul Menage recommends that one file has
>> just one meaningful value.
> 
> That's based on examples from other virtual filesystems such as sysfs.
> 

Even during the CKRM days (when configfs was used), the recommendation
from the configfs folks was the same. I sometimes worry about the
extra pinned dentries created with this logic/rule though.

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
