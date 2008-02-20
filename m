Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1K4jIov020775
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 10:15:18 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1K4jIVw1147108
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 10:15:18 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1K4jM5B015110
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 04:45:23 GMT
Message-ID: <47BBAF63.7040101@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 10:11:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220100333.a014083c.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802200355220.3569@blonde.site> <20080220133742.94a0b1b6.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802200436380.7234@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0802200436380.7234@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
>> On Wed, 20 Feb 2008 04:14:58 +0000 (GMT)
>> Hugh Dickins <hugh@veritas.com> wrote:
>>
>>> What's needed, I think, is something in struct mm, a flag or a reserved value
>>> in mm->mem_cgroup, to say don't do any of this mem_cgroup stuff on me; and a cgroup
>>> fs interface to set that, in the same way as force_empty is done.
>> I agree here. I believe we need "no charge" flag at least to the root group.
>> For root group, it's better to have boot option if not complicated.
> 
> I expect we'll end up wanting both the cgroupfs interface and the boot
> option for the root; but yes, for now, the boot option would be enough.
> 
> Hugh

Yes a boot option would be good for now. Sorry, I've just woken up and reading
through other emails and trying to catch up with the threads. I'll try and
respond to the other emails soon.

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
