Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5910C6B003A
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 21:50:21 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so451343pdj.22
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:50:21 -0700 (PDT)
Date: Thu, 26 Sep 2013 03:50:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
Message-ID: <20130926015016.GM18242@two.firstfloor.org>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
 <52437128.7030402@linux.vnet.ibm.com>
 <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org>
 <20130925234734.GK18242@two.firstfloor.org>
 <52438AA9.3020809@linux.intel.com>
 <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 25, 2013 at 06:21:29PM -0700, Andrew Morton wrote:
> On Wed, 25 Sep 2013 18:15:21 -0700 Arjan van de Ven <arjan@linux.intel.com> wrote:
> 
> > On 9/25/2013 4:47 PM, Andi Kleen wrote:
> > >> Also, the changelogs don't appear to discuss one obvious downside: the
> > >> latency incurred in bringing a bank out of one of the low-power states
> > >> and back into full operation.  Please do discuss and quantify that to
> > >> the best of your knowledge.
> > >
> > > On Sandy Bridge the memry wakeup overhead is really small. It's on by default
> > > in most setups today.
> > 
> > btw note that those kind of memory power savings are content-preserving,
> > so likely a whole chunk of these patches is not actually needed on SNB
> > (or anything else Intel sells or sold)
> 
> (head spinning a bit).  Could you please expand on this rather a lot?

As far as I understand there is a range of aggressiveness. You could
just group memory a bit better (assuming you can sufficiently predict
the future or have some interface to let someone tell you about it).

Or you can actually move memory around later to get as low footprint
as possible.

This patchkit seems to do both, with the later parts being on the
aggressive side (move things around) 

If you had non content preserving memory saving you would 
need to be aggressive as you couldn't afford any mistakes.

If you had very slow wakeup you also couldn't afford mistakes,
as those could cost a lot of time.

On SandyBridge is not slow and it's preserving, so some mistakes are ok.

But being aggressive (so move things around) may still help you saving
more power -- i guess only benchmarks can tell. It's a trade off between
potential gain and potential worse case performance regression.
It may also depend on the workload.

At least right now the numbers seem to be positive.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
