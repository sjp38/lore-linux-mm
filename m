Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 329426B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 05:57:25 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 18 Apr 2013 19:48:06 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 786D72BB0052
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 19:57:12 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3I9hY2056426728
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 19:43:35 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3I9v9N4027415
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 19:57:10 +1000
Message-ID: <516FC2D1.9020809@linux.vnet.ibm.com>
Date: Thu, 18 Apr 2013 15:24:25 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com> <516ED378.2000406@linux.intel.com>
In-Reply-To: <516ED378.2000406@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/17/2013 10:23 PM, Srinivas Pandruvada wrote:
> On 04/09/2013 02:45 PM, Srivatsa S. Bhat wrote:
>> [I know, this cover letter is a little too long, but I wanted to clearly
>> explain the overall goals and the high-level design of this patchset in
>> detail. I hope this helps more than it annoys, and makes it easier for
>> reviewers to relate to the background and the goals of this patchset.]
>>
>>
>> Overview of Memory Power Management and its implications to the Linux MM
>> ========================================================================
>>
[...]
>>
> One thing you need to prevent is boot time allocation. You have to make
> sure that frequently accessed per node data stored at the end of memory
> will keep all ranks of memory active.
> 

I think you meant to say "... stored at the end of memory will NOT keep all
ranks of memory active".

Yep, that's a good point! I'll think about how to achieve that. Thanks!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
