Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 4C61A6B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 10:51:27 -0400 (EDT)
Date: Thu, 16 May 2013 16:51:24 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/THP: Use pmd_populate to update the pmd with
 pgtable_t pointer
Message-ID: <20130516145124.GP5181@redhat.com>
References: <1368347715-24597-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <871u9b56t2.fsf@linux.vnet.ibm.com>
 <20130513141357.GL27980@redhat.com>
 <87y5bj3pnc.fsf@linux.vnet.ibm.com>
 <87txm6537l.fsf@linux.vnet.ibm.com>
 <20130516131804.GO5181@redhat.com>
 <87bo8bxar0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bo8bxar0.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Thu, May 16, 2013 at 07:55:23PM +0530, Aneesh Kumar K.V wrote:
> Andrea Arcangeli <aarcange@redhat.com> writes:
> 
> > Hi Aneesh,
> >
> > On Mon, May 13, 2013 at 08:36:38PM +0530, Aneesh Kumar K.V wrote:
> >> https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-May/106406.html
> >
> > You need ACCESS_ONCE() in all "pgd = ACCESS_ONCE(*pgdp)", "pud =
> > ACCESS_ONCE(*pudp)" otherwise the compiler could decide your change is
> > a noop.
> 
> Will do. I guess we have similar one for x86 here 

Exactly.

> 
> http://article.gmane.org/gmane.linux.kernel/1483617
> 
> May be ppc64 gup walk also need similar changes ?

I think so, yes.

> > I think you could remove the #ifdef CONFIG_TRANSPARENT_HUGEPAGE too.
> 
> That was becaue i had pte_pmd available only with that config. I will
> see if we can fix that.

Ok, up to you.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
