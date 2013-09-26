Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2FB6B0055
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 21:21:33 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so570758pad.30
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:21:33 -0700 (PDT)
Date: Wed, 25 Sep 2013 18:21:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
Message-Id: <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org>
In-Reply-To: <52438AA9.3020809@linux.intel.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
	<52437128.7030402@linux.vnet.ibm.com>
	<20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org>
	<20130925234734.GK18242@two.firstfloor.org>
	<52438AA9.3020809@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 25 Sep 2013 18:15:21 -0700 Arjan van de Ven <arjan@linux.intel.com> wrote:

> On 9/25/2013 4:47 PM, Andi Kleen wrote:
> >> Also, the changelogs don't appear to discuss one obvious downside: the
> >> latency incurred in bringing a bank out of one of the low-power states
> >> and back into full operation.  Please do discuss and quantify that to
> >> the best of your knowledge.
> >
> > On Sandy Bridge the memry wakeup overhead is really small. It's on by default
> > in most setups today.
> 
> btw note that those kind of memory power savings are content-preserving,
> so likely a whole chunk of these patches is not actually needed on SNB
> (or anything else Intel sells or sold)

(head spinning a bit).  Could you please expand on this rather a lot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
