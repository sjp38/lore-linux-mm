Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B734E6B0132
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 04:36:44 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id p10so7440202pdj.5
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 01:36:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id jm11si16078679pbb.8.2014.11.10.01.36.42
        for <linux-mm@kvack.org>;
        Mon, 10 Nov 2014 01:36:43 -0800 (PST)
Message-ID: <5460858F.5050608@intel.com>
Date: Mon, 10 Nov 2014 17:29:51 +0800
From: Xiaokang <xiaokang.qin@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc/smaps: add proportional size of anonymous page
References: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com> <545D3AFB.1080308@intel.com>
In-Reply-To: <545D3AFB.1080308@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: fengwei.yin@intel.com

On 11/08/2014 05:34 AM, Dave Hansen wrote:
> On 11/07/2014 12:31 AM, Xiaokang Qin wrote:
>> The "proportional anonymous page size" (PropAnonymous) of a process is the count of
>> anonymous pages it has in memory, where each anonymous page is devided by the number
>> of processes sharing it.
>
> This seems like the kind of thing that should just be accounted for in
> the existing pss metric.  Why do we need a new, separate one?
>
Hi, Dave

For some case especially under Android, anonymous page sharing is 
common, for example:
70323000-70e41000 rw-p 00000000 fd:00 120004 
  /data/dalvik-cache/x86/system@framework@boot.art
Size:              11384 kB
Rss:                8840 kB
Pss:                 927 kB
Shared_Clean:       5720 kB
Shared_Dirty:       2492 kB
Private_Clean:        16 kB
Private_Dirty:       612 kB
Referenced:         7896 kB
Anonymous:          3104 kB
PropAnonymous:       697 kB
AnonHugePages:         0 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB
The only Anonymous here is confusing to me. What I really want to know 
is how many anonymous page is there in Pss. After exposing 
PropAnonymous, we could know 697/927 is anonymous in Pss.
I suppose the Pss - PropAnonymous = Proportional Page cache size for 
file based memory and we want to break down the page cache into process 
level, how much page cache each process consumes.

Regards,
Xiaokang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
