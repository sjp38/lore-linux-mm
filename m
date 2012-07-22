Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 2300A6B004D
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 13:34:36 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so11674804pbb.14
        for <linux-mm@kvack.org>; Sun, 22 Jul 2012 10:34:35 -0700 (PDT)
Date: Sun, 22 Jul 2012 10:34:29 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
Message-ID: <20120722173429.GF5144@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120719113915.GC2864@tiehlicka.suse.cz>
 <87r4s8gcwe.fsf@skywalker.in.ibm.com>
 <20120719123820.GG2864@tiehlicka.suse.cz>
 <87ipdjc15j.fsf@skywalker.in.ibm.com>
 <20120720080639.GC12434@tiehlicka.suse.cz>
 <87d33qmeb9.fsf@skywalker.in.ibm.com>
 <20120720195643.GC21218@google.com>
 <500A107D.9060404@jp.fujitsu.com>
 <20120721024657.GA7962@dhcp-172-17-108-109.mtv.corp.google.com>
 <500A2A79.5030705@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <500A2A79.5030705@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, liwanp@linux.vnet.ibm.com, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

Hello, Kamezawa-san.

On Sat, Jul 21, 2012 at 01:05:13PM +0900, Kamezawa Hiroyuki wrote:
> Maybe it's better to remove memcg's pre_destroy() at all and do the job
> in asynchronus thread called by ->destroy().

It doesn't really matter as long as ->pre_destroy() doesn't fail.  The
only meaningful difference between them is that pre_destroy() is
called before css refs reach zero (and can be used to drop css refs so
that destruction can happen).

> I'll cook a patch again.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
