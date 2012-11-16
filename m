Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id C77086B0072
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:29:15 -0500 (EST)
Message-ID: <50A6B01F.3000708@linux.intel.com>
Date: Fri, 16 Nov 2012 13:29:03 -0800
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 11/11] thp, vmstat: implement HZP_ALLOC and HZP_ALLOC_FAILED
 events
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-12-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.00.1211141541000.22537@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211141541000.22537@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On 11/14/2012 03:41 PM, David Rientjes wrote:
> 
> Nobody is going to know what hzp_ is, sorry.  It's better to be more 
> verbose and name them what they actually are: THP_ZERO_PAGE_ALLOC and 
> THP_ZERO_PAGE_ALLOC_FAILED.  But this would assume we want to lazily 
> allocate them, which I disagree with hpa about.
> 

You want to permanently sit on 2 MiB of memory on all systems?  That
being an obvious nonstarter, then you end up having to make some kind of
static control, with all the problems that entails (if Linus had not set
his foot down on tunables a long time ago, we today would have had a
Linux mm which only performed well if you manually set hundreds or
thousands of parameters) you either have lazy allocation or you go with
the virtual huge zero page solution and just accept that either is going
to perform poorly under some set of pathological circumstances.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
