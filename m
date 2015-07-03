Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 53DEF280281
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 16:13:42 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so117214695wid.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 13:13:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si16314587wjw.157.2015.07.03.13.13.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 13:13:40 -0700 (PDT)
Date: Fri, 3 Jul 2015 21:13:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
Message-ID: <20150703201331.GF6812@suse.de>
References: <20150702072621.GB12547@dhcp22.suse.cz>
 <20150702160341.GC9456@thunk.org>
 <55956204.2060006@gmail.com>
 <20150703144635.GE9456@thunk.org>
 <5596A20F.6010509@gmail.com>
 <20150703150117.GA3688@dhcp22.suse.cz>
 <5596A42F.60901@gmail.com>
 <20150703164944.GG9456@thunk.org>
 <5596BDB6.5060708@gmail.com>
 <20150703184501.GJ9456@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150703184501.GJ9456@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, nick <xerofoify@gmail.com>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 03, 2015 at 02:45:02PM -0400, Theodore Ts'o wrote:
> On Fri, Jul 03, 2015 at 12:52:06PM -0400, nick wrote:
> > I agree with you 100 percent. The reason I can't test this is I don't have the
> > hardware otherwise I would have tested it by now.
> 
> Then don't send the patch out.  Work on some other piece of part of
> the kernel, or better yet, some other userspace code where testing is
> easier.  It's really quite simple.
> 
> You don't have the technical skills, or at this point, the reputation,
> to send patches without tesitng them first.  The fact that sometimes
> people like Linus will send out a patch labelled with "COMPLETELY
> UNTESTED", is because he's skilled and trusted enough that he can get
> away with it.

It's not just that. In all cases I'm aware of, Linus was illustrating his
point by means of a patch during a discussion. It was expected that the
developer or user that started the discussion would take that patch and run
with it if it was heading in the correct direction. In exceptional cases,
the patch would be merged after a confirmation from that developer or user
that the patch worked for whatever problem they faced. The only time I've
seen a COMPLETELY UNTESTED patch merged was when it was painfully obvious it
was correct and more importantly, it solved a specific problem. Linus is not
the only developer that does this style of discussion through untested patch.

In other cases where an untested patch has been merged, it was either due to
it being exceptionally trivial or a major API change that affects a number
of subsystems (like adding a new filesystem API for example). In the former
case, it's usually self-evident and often tacked onto a larger series where
there is a degree of trust. In the latter case, all cases they can test
have been covered and the code for the remaining hardware was altered in
a very similar manner. This also lends some confidence that the transform
is ok because similar transforms were tested and known to be correct.

For trivial patches that alter just return values there are a few hazards. A
mistake can be made introducing a real bug with the upside being marginal or
non-existent. That's a very poor tradeoff and generally why checkpatch-only
patches fall by the wayside. Readability is a two-edged sword. Maybe the
code is marginally easier to read but it's sometimes offset by the fact
that git blame no longer points to the important origin of the code. If
a real bug is being investigated then all the cleanup patches have to be
identified and dismissed which consumes time and concentration.

Cleanups in my opinion are ok in two cases. The first is if it genuinely
makes the code much easier to follow. In cases where I've seen this, it was
done because the code was either unreadable or it was in preparation for a
more relevant patch series that was then easier to review and justified the
cleanup. The second is where the affected code is being heavily modified
anyway so the cleanup while you are there is both useful and does not
impact git blame.

This particular patch does not match any of the criteria. The DRM patch
may or may not be correct but there is no way I'd expect something like
it to be picked up without testing or in reference to a bug report.

For this patch, NAK. Nick, from me at least consider any similar patch
affecting mm/ that modifies return values or types without being part of
a larger series that addresses a particular problem to be silently NAKed
or filed under "doesn't matter" by me.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
