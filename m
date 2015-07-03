Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8BECB280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 12:49:54 -0400 (EDT)
Received: by ykdr198 with SMTP id r198so99759059ykd.3
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 09:49:54 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id m62si6603970ykc.95.2015.07.03.09.49.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 09:49:53 -0700 (PDT)
Date: Fri, 3 Jul 2015 12:49:44 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
Message-ID: <20150703164944.GG9456@thunk.org>
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
 <20150702072621.GB12547@dhcp22.suse.cz>
 <20150702160341.GC9456@thunk.org>
 <55956204.2060006@gmail.com>
 <20150703144635.GE9456@thunk.org>
 <5596A20F.6010509@gmail.com>
 <20150703150117.GA3688@dhcp22.suse.cz>
 <5596A42F.60901@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5596A42F.60901@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 03, 2015 at 11:03:11AM -0400, nick wrote:
> 
> The reason I am doing this is Ted is trying to find a bug that I
> fixed in order to prove to Greg Kroah Hartman I have
> changed. Otherwise I would be pushing this through the drm
> maintainer(s).

I am trying to determine if you have changed.  Your comment justifying
your lack of testing because "it's hard to test" is ample evidence
that you have *not* changed.

Simply coming up with a commit that happens to be correct is a
necessary, but not sufficient condition.  Especially when you feel
that you need to send dozens of low-value patches and hope that one of
them is correct, and then use that as "proof".  It's the attitude
which is problem, not whether or not you can manage to come up with a
correct patch.

I've described to you what you need to do in order to demonstrate that
you have the attitude and inclinations in order to be a kernel
developer that a maintainer can trust as being capable of authoring a
patch that doesn't create more problems than whatever benefits it
might have.  I respectfully ask that you try to work on that, and stop
bothering me (and everyone else).

Best regards,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
