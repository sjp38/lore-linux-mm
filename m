Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 355036B00B9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 20:06:27 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id x10so209460pdj.6
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 17:06:26 -0800 (PST)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id tu2si5349472pbc.99.2014.02.25.17.06.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 17:06:26 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id um1so215927pbc.33
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 17:06:25 -0800 (PST)
Date: Tue, 25 Feb 2014 17:05:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
In-Reply-To: <20140225171528.GJ4407@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1402251652230.979@eggly.anvils>
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <20140225171528.GJ4407@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Graf <agraf@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Kay Sievers <kay@vrfy.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, 25 Feb 2014, Johannes Weiner wrote:
> On Tue, Feb 25, 2014 at 12:28:04AM +0100, Alexander Graf wrote:
> > Configuration of tunables and Linux virtual memory settings has traditionally
> > happened via sysctl. Thanks to that there are well established ways to make
> > sysctl configuration bits persistent (sysctl.conf).
> > 
> > KSM introduced a sysfs based configuration path which is not covered by user
> > space persistent configuration frameworks.
> > 
> > In order to make life easy for sysadmins, this patch adds all access to all
> > KSM tunables via sysctl as well. That way sysctl.conf works for KSM as well,
> > giving us a streamlined way to make KSM configuration persistent.
> 
> ksm can be a module, so this won't work.

That's news to me.  Are you writing of some Red Hat patches, or just
misled by the "module_init(ksm_init)" which used the last line of ksm.c?

I don't mind Alex's patch, but I do think the same should be done for
THP as for KSM, and a general solution more attractive than more #ifdefs
one by one.  Should a general solution just be in userspace, in sysctl(8)?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
