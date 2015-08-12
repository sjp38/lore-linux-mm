Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8E36B6B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 21:53:57 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so2922307pac.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 18:53:57 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id bm6si6759120pad.85.2015.08.11.18.53.56
        for <linux-mm@kvack.org>;
        Tue, 11 Aug 2015 18:53:56 -0700 (PDT)
Subject: Re: [PATCH 1/5] x86, gfp: Cache best near node for memory allocation.
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
 <1436261425-29881-2-git-send-email-tangchen@cn.fujitsu.com>
 <20150715214802.GL15934@mtj.duckdns.org> <55C03332.2030808@cn.fujitsu.com>
 <55C0725B.80201@linux.intel.com> <55C6EFFF.5070605@cn.fujitsu.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <55CAA72F.8050308@linux.intel.com>
Date: Wed, 12 Aug 2015 09:53:51 +0800
MIME-Version: 1.0
In-Reply-To: <55C6EFFF.5070605@cn.fujitsu.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2015/8/9 14:15, Tang Chen wrote:
> Hi Liu,
> 
> Have you posted your new patches ?
> (I mean memory-less node support patches.)
Hi Chen,
	I have rebased my patches to v4.2-rc4, but unfortunately
it breaks. Seems there are some changes in x86 NUMA support since
3.17. I need some time to figure it out.

> 
> If you are going to post them, please cc me.
Sure.

> 
> And BTW, how did you reproduce the memory-less node problem ?
> Do you have a real memory-less node on your machine ?
Yes, we have a system with memoryless nodes.
Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
