Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6836B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 22:58:17 -0500 (EST)
Received: by mail-oa0-f42.google.com with SMTP id i7so8641767oag.1
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 19:58:16 -0800 (PST)
Received: from g4t0014.houston.hp.com (g4t0014.houston.hp.com. [15.201.24.17])
        by mx.google.com with ESMTPS id m4si7242193oel.87.2014.02.10.19.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 19:58:16 -0800 (PST)
Message-ID: <1392091093.2501.7.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 10 Feb 2014 19:58:13 -0800
In-Reply-To: <20140210151354.68fe414f81335d4ce0e4c550@linux-foundation.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
	 <20140210151354.68fe414f81335d4ce0e4c550@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, 2014-02-10 at 15:13 -0800, Andrew Morton wrote:
> On Mon, 10 Feb 2014 12:27:44 -0500 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > HugeTLB command-line option hugepages= allows the user to specify how many
> > huge pages should be allocated at boot. On NUMA systems, this argument
> > automatically distributes huge pages allocation among nodes, which can
> > be undesirable.
> 
> Grumble.  "can be undesirable" is the entire reason for the entire
> patchset.  We need far, far more detail than can be conveyed in three
> words, please!

One (not so real-world) scenario that comes right to mind which can
benefit for such a feature is the ability to study socket/node scaling
for hugepage aware applications. Yes, we do have numactl to bind
programs to resources, but I don't mind having a way of finer graining
hugetlb allocations, specially if it doesn't hurt anything.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
