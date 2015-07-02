Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id DEDE9280246
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 12:03:53 -0400 (EDT)
Received: by ykfy125 with SMTP id y125so72458257ykf.1
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 09:03:53 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id n124si4189837ywe.197.2015.07.02.09.03.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 09:03:52 -0700 (PDT)
Date: Thu, 2 Jul 2015 12:03:41 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
Message-ID: <20150702160341.GC9456@thunk.org>
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
 <20150702072621.GB12547@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150702072621.GB12547@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Nicholas Krause <xerofoify@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 02, 2015 at 09:26:21AM +0200, Michal Hocko wrote:
> On Wed 01-07-15 14:27:57, Nicholas Krause wrote:
> > This makes the function zap_huge_pmd have a return type of bool
> > now due to this particular function always returning one or zero
> > as its return value.
> 
> How does this help anything? IMO this just generates a pointless churn
> in the code without a good reason.

Hi Michal,

My recommendation is to ignore patches sent by Nick.  In my experience
he doesn't understand code before trying to make mechanical changes,
and very few of his patches add any new value, and at least one that
he tried to send me just 2 weeks or so ago (cherry-picked to try to
"prove" why he had turned over a new leaf, so that I would support the
removal of his e-mail address from being blacklisted on
vger.kernel.org) was buggy, and when I asked him some basic questions
about what the code was doing, it was clear he had no clue how the
seq_file abstraction worked.  This didn't stop him from trying to
patch the code, and if he had tested it, it would have crashed and
burned instantly.

Of course, do whatevery you want, but IMHO it's not really not worth
your time to deal with his patches, and if you reply, most people
won't see his original e-mail since the vger.kernel.org blacklist is
still in effect.

Regards,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
