Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 033C76B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:47:31 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id hw13so2727776qab.34
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:47:31 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id dk2si4840834qcb.16.2014.06.13.08.47.30
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 08:47:30 -0700 (PDT)
Date: Fri, 13 Jun 2014 10:47:27 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
In-Reply-To: <alpine.DEB.2.02.1406111553430.27885@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1406131045340.913@gentwo.org>
References: <20140608181436.17de69ac@redhat.com> <CAE9FiQXpUbAOinEK-1PSFyGKqpC_FHN0sjP0xvD0ChrXR5GdAw@mail.gmail.com> <20140609150353.75eff02b@redhat.com> <CAE9FiQUWZxvCS82cH=n-NF+nhTQ83J+7M3gHdXGu2S1Qk3xL_g@mail.gmail.com> <20140611092337.35794bc0@redhat.com>
 <alpine.DEB.2.10.1406110852280.7977@gentwo.org> <alpine.DEB.2.02.1406111553430.27885@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, 11 Jun 2014, David Rientjes wrote:

> > > Yes, but the question is: why?
> >
> > zones need to be aligned so that the huge pages order and other page
> > orders allocated from the page allocator are at their "natural alignment".
> > Otherwise huge pages cannot be mapped properly and various I/O devices
> > may encounter issues if they rely on the natural alignment.
> >
>
> Any reason not to align to HUGETLB_PAGE_ORDER on x86 instead of
> ZONE_ALIGN?

if MAX_ORDER = Hugetlb order then no issue.

However, if there are devices that require larger order pages (dont know
if such devices exist) then there may be an issue. SGI UV DMA engine,
graphics or some other device?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
