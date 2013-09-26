Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E9D246B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 21:14:23 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so411550pdj.39
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:14:23 -0700 (PDT)
Message-ID: <52438A6B.30202@linux.intel.com>
Date: Wed, 25 Sep 2013 18:14:19 -0700
From: Arjan van de Ven <arjan@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org>
In-Reply-To: <20130925234734.GK18242@two.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/25/2013 4:47 PM, Andi Kleen wrote:
>> Also, the changelogs don't appear to discuss one obvious downside: the
>> latency incurred in bringing a bank out of one of the low-power states
>> and back into full operation.  Please do discuss and quantify that to
>> the best of your knowledge.
>
> On Sandy Bridge the memry wakeup overhead is really small. It's on by default
> in most setups today.

yet grouping is often defeated (in current systems) due to hw level interleaving ;-(
sometimes that's a bios setting though.

in internal experimental bioses we've been able to observe a "swing" of a few watts
(not with these patches but with some other tricks)...
I'm curious to see how these patches do for Srivatsa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
