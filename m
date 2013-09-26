Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E6FAD6B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:13:31 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so1304774pab.27
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 06:13:31 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 18:43:26 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6CFF8125803F
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:43:36 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QDDKWJ45875214
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:43:21 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8QDDL9i026978
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:43:22 +0530
Message-ID: <524431FF.50904@linux.vnet.ibm.com>
Date: Thu, 26 Sep 2013 18:39:19 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org> <52438A6B.30202@linux.intel.com>
In-Reply-To: <52438A6B.30202@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, thomas.abraham@linaro.org, amit.kachhap@linaro.org

On 09/26/2013 06:44 AM, Arjan van de Ven wrote:
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
> yet grouping is often defeated (in current systems) due to hw level
> interleaving ;-(
> sometimes that's a bios setting though.
> 

True, and I plan to tweak those hardware settings in the prototype powerpc
platform and evaluate the power vs performance trade-offs of various
interleaving schemes in conjunction with this patchset.

> in internal experimental bioses we've been able to observe a "swing" of
> a few watts
> (not with these patches but with some other tricks)...

Great! So, would you have the opportunity to try out this patchset as well
on those systems that you have? I can modify the patchset to take memory
region info from whatever source you want me to take it from and then we'll
have realistic power-savings numbers to evaluate this patchset and its benefits
on Intel/x86 platforms.

> I'm curious to see how these patches do for Srivatsa
> 

As I mentioned in my other mail, I don't yet have a setup for doing actual
power-measurements. Hence, so far I was focussing on the algorithmic aspects
of the patchset and was trying to get an excellent consolidation ratio,
without hurting performance too much. Going forward, I'll work on getting the
power-measurements as well on the powerpc platform that I have.
 
Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
