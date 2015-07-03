Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id E4310280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 10:46:44 -0400 (EDT)
Received: by ykdv136 with SMTP id v136so97584682ykd.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 07:46:44 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id u131si1322994ywb.36.2015.07.03.07.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 07:46:44 -0700 (PDT)
Date: Fri, 3 Jul 2015 10:46:35 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
Message-ID: <20150703144635.GE9456@thunk.org>
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
 <20150702072621.GB12547@dhcp22.suse.cz>
 <20150702160341.GC9456@thunk.org>
 <55956204.2060006@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55956204.2060006@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 02, 2015 at 12:08:36PM -0400, nick wrote:
> I looked into that patch further and would were correct it was wrong.
> However here is a bug fix for the drm driver code that somebody else
> stated was right but haven gotten a reply to from the maintainer and
> have tried resending.

Hi Nick,

Don't bother sending more low-value patches like this; they don't
impress me.  Send me a patch that fixes a deep bug, where you can
demonstrate that you understand the underlying design of the code, can
point out a flaw, and then explain why your patch is an improvement,
and documents how you tested it.  Or do something beyond changing
return values or return types, and optimize some performance-critical
part of the kernel, and in the commit description, explain why it
improves things, how you measured the performance improvement, and why
this is applicable in a real-life situation.

Even a broken clock can be right twice a day, and the fact that it is
possible that you can author a correct patch isn't all that
impressive.  You need to understand deep understanding of the code you
are modifying, and or else it's not worth my time to go through a
large number of low-value patches that don't really improve the code
base much, when the risk that you have accidentally introduced a bug
is high given that (a) you've demonstrated an inability to explain
some of your patches, and (b) in many cases, you have no fear about
sending patches that you can't personally test.  These two
shortcomings in combination are fatal.

If you can demonstrate that you can become a thoughtful and careful
coder, I would be most pleased to argue to Greg K-H that you have
turned over a new leaf.  To date, however, you have not demonstrated
any of the above, and you've made me regret that I've tried to waste
time looking at your patches that you've sent me in the hopes of
convincing me that you've really changed --- when it's clear you
haven't.  I do hope that, one day, you will be able to be a good
coder.  But that day is clearly not today.

Best regards,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
