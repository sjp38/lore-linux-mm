Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id D97C86B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:20:43 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so1134557pbb.27
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 06:20:43 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 18:50:38 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 09FD7394005E
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:50:21 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QDKYZp47775940
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:50:34 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8QDKXRl024345
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:50:34 +0530
Message-ID: <524433AF.8010102@linux.vnet.ibm.com>
Date: Thu, 26 Sep 2013 18:46:31 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org> <52438AA9.3020809@linux.intel.com>
In-Reply-To: <52438AA9.3020809@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, thomas.abraham@linaro.org, amit.kachhap@linaro.org

On 09/26/2013 06:45 AM, Arjan van de Ven wrote:
> On 9/25/2013 4:47 PM, Andi Kleen wrote:
>>> Also, the changelogs don't appear to discuss one obvious downside: the
>>> latency incurred in bringing a bank out of one of the low-power states
>>> and back into full operation.  Please do discuss and quantify that to
>>> the best of your knowledge.
>>
>> On Sandy Bridge the memry wakeup overhead is really small. It's on by
>> default
>> in most setups today.
> 
> btw note that those kind of memory power savings are content-preserving,
> so likely a whole chunk of these patches is not actually needed on SNB
> (or anything else Intel sells or sold)
> 

Umm, why not? By consolidating the allocations to fewer memory regions,
this patchset also indirectly consolidates the *references* as well. And
its the lack of memory references that really makes the hardware transition
the unreferenced banks to low-power (content-preserving) states. So from what
I understand, this patchset should provide noticeable benefits on Intel/SNB
platforms as well.

(BTW, even in the prototype powerpc hardware that I mentioned, the primary
memory power savings is expected to come from content-preserving states. So
its not like this patchset was designed only for content-losing/full-poweroff
type of scenarios).

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
