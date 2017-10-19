Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59ED06B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:57:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z11so4595993pfk.23
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 18:57:19 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l25si7411820pfe.112.2017.10.18.18.57.17
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 18:57:18 -0700 (PDT)
Date: Thu, 19 Oct 2017 10:57:06 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: Fix false positive by LOCKDEP_CROSSRELEASE
Message-ID: <20171019015705.GD32368@X58A-UD3R>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
 <1508336995.2923.2.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508336995.2923.2.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

On Wed, Oct 18, 2017 at 02:29:56PM +0000, Bart Van Assche wrote:
> On Wed, 2017-10-18 at 18:38 +0900, Byungchul Park wrote:
> > Several false positives were reported, so I tried to fix them.
> > 
> > It would be appreciated if you tell me if it works as expected, or let
> > me know your opinion.
> 
> What I have been wondering about is whether the crosslock checking makes
> sense from a conceptual point of view. I tried to find documentation for the
> crosslock checking in Documentation/locking/lockdep-design.txt but
> couldn't find a description of the crosslock checking. Shouldn't it be
> documented somewhere what the crosslock checks do and what the theory is
> behind these checks?

Documentation/locking/crossrelease.txt would be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
