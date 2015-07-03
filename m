Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 086F028027A
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 14:45:11 -0400 (EDT)
Received: by ykdy1 with SMTP id y1so102121008ykd.2
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 11:45:10 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id q6si6819381ykb.10.2015.07.03.11.45.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 11:45:08 -0700 (PDT)
Date: Fri, 3 Jul 2015 14:45:02 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
Message-ID: <20150703184501.GJ9456@thunk.org>
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
 <20150702072621.GB12547@dhcp22.suse.cz>
 <20150702160341.GC9456@thunk.org>
 <55956204.2060006@gmail.com>
 <20150703144635.GE9456@thunk.org>
 <5596A20F.6010509@gmail.com>
 <20150703150117.GA3688@dhcp22.suse.cz>
 <5596A42F.60901@gmail.com>
 <20150703164944.GG9456@thunk.org>
 <5596BDB6.5060708@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5596BDB6.5060708@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 03, 2015 at 12:52:06PM -0400, nick wrote:
> I agree with you 100 percent. The reason I can't test this is I don't have the
> hardware otherwise I would have tested it by now.

Then don't send the patch out.  Work on some other piece of part of
the kernel, or better yet, some other userspace code where testing is
easier.  It's really quite simple.

You don't have the technical skills, or at this point, the reputation,
to send patches without tesitng them first.  The fact that sometimes
people like Linus will send out a patch labelled with "COMPLETELY
UNTESTED", is because he's skilled and trusted enough that he can get
away with it.  You have neither of those advantages.

Best regards,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
