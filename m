Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 078D36B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 06:17:33 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so34437285wiw.14
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 03:17:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si37328093wiw.78.2014.12.04.03.17.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 03:17:32 -0800 (PST)
Date: Thu, 4 Dec 2014 11:17:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to
 p[te|md]_protnone_numa
Message-ID: <20141204111728.GL6043@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
 <1416578268-19597-4-git-send-email-mgorman@suse.de>
 <1417473762.7182.8.camel@kernel.crashing.org>
 <87k32ah5q3.fsf@linux.vnet.ibm.com>
 <1417551115.27448.7.camel@kernel.crashing.org>
 <87lhmobvuu.fsf@linux.vnet.ibm.com>
 <20141203155242.GE6043@suse.de>
 <87d280bqfw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87d280bqfw.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Wed, Dec 03, 2014 at 10:50:35PM +0530, Aneesh Kumar K.V wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > On Wed, Dec 03, 2014 at 08:53:37PM +0530, Aneesh Kumar K.V wrote:
> >> Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:
> >> 
> >> > On Tue, 2014-12-02 at 12:57 +0530, Aneesh Kumar K.V wrote:
> >> >> Now, hash_preload can possibly insert an hpte in hash page table even if
> >> >> the access is not allowed by the pte permissions. But i guess even that
> >> >> is ok. because we will fault again, end-up calling hash_page_mm where we
> >> >> handle that part correctly.
> >> >
> >> > I think we need a test case...
> >> >
> >> 
> >> I ran the subpageprot test that Paul had written. I modified it to ran
> >> with selftest. 
> >> 
> >
> > It's implied but can I assume it passed? 
> 
> Yes.
> 
> -bash-4.2# ./subpage_prot 
> test: subpage_prot
> tags: git_version:v3.17-rc3-13511-g0cd3756
> allocated malloc block of 0x4000000 bytes at 0x0x3fffb0d10000
> testing malloc block...
> OK
> success: subpage_prot
> -bash-4.2# 
> 

Thanks for adding that and double checking. I won't pick up the patch as
part of this series because it's not directly related but I would strongly
suggest sending the patch separately.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
