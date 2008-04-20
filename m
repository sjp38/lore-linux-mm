Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3K7lRjU020325
	for <linux-mm@kvack.org>; Sun, 20 Apr 2008 13:17:27 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3K7lMQm929940
	for <linux-mm@kvack.org>; Sun, 20 Apr 2008 13:17:23 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3K7lYDE031171
	for <linux-mm@kvack.org>; Sun, 20 Apr 2008 07:47:35 GMT
Message-ID: <480AF43D.1090405@linux.vnet.ibm.com>
Date: Sun, 20 Apr 2008 13:13:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Memory controller hierarchy support (v1)
References: <20080419053551.10501.44302.sendpatchset@localhost.localdomain> <4809CDB7.3000105@openvz.org>
In-Reply-To: <4809CDB7.3000105@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Paul Menage <menage@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> 
> Are you going to split this patch? As is it looks rather huge :)
> 

Sure

>> TODO's/Open Questions
>>
>> 1. We need to hold cgroup_mutex while walking through the children
>>    in reclaim. We need to figure out the best way to do so. Should
>>    cgroups provide a helper function/macro for it?
>> 2. Do not allow children to have a limit greater than their parents.
>> 3. Allow the user to select if hierarchial support is required
>> 4. Fine tune reclaim from children logic
>>
> 
> I though about it recently. Can we have a cgroup file, which will
> control whether to attach a res_counter to the parent? This will
> address the YEMEMOTO's question about the performance.
> 

It's one of the TODOS

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
