Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C43BF6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 16:23:30 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so177122902pad.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 13:23:30 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id lp6si16229130pab.69.2015.03.30.13.23.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 13:23:29 -0700 (PDT)
Received: by pddn5 with SMTP id n5so70213139pdd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 13:23:28 -0700 (PDT)
Date: Mon, 30 Mar 2015 13:23:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 1/2] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory
In-Reply-To: <20150330142336.GB17678@akamai.com>
Message-ID: <alpine.LSU.2.11.1503301307490.2485@eggly.anvils>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com> <alpine.LSU.2.11.1503291801400.1052@eggly.anvils> <20150330142336.GB17678@akamai.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Mon, 30 Mar 2015, Eric B Munson wrote:
> On Sun, 29 Mar 2015, Hugh Dickins wrote:
> > 
> > Eric, I apologize for bringing you in to the discussion, and then
> > ignoring your input.  I understand that you would like MAP_HUGETLB
> > to behave more understandably.  We can all agree that the existing
> > behavior is unsatisfying.  But it's many years too late now to 
> > change it around - and I suspect that a full exercise to do so would
> > actually discover some good reasons why the original choices were made.
> 
> No worries, my main concern was avoiding the confusion that led me down
> the rabbit hole of compaction and mlock.  As long as the documentation,
> man pages, and the code all agree I am satisfied.  I would have
> preferred to make the code match the docs, but I understand that
> changing the code now introduces a risk of breaking userspace.
> 
> It is charitable of you to assume that there were good reasons for the
> original decision.  But as the author of the code in question, I suspect
> the omission was one of my own inexperience.

No, you are both too modest and too arrogant :)

You were extending the existing hugetlbfs infrastructure to be
accessible through a MAP_HUGETLB interface.  You therefore inherited
the defects (some probably necessary, others perhaps not) of the
original hugetlbfs implementation, which is where this disagreeable
behaviour comes from.

If you were to ask for MAP_HUGETLB to behave differently from mapping
hugetlbfs here, I would shout no.  For a start, we'd have to add a
VM_HUGETLB2 flag so that each place that tests VM_HUGETLB (usually
through is_vm_hugetlb_page(vma) - sic) could decide how to behave
instead.

I for one have neither time nor inclination to write or review
any such patch.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
