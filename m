Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id BC7096B0183
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 18:54:05 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id rl12so411482iec.25
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:54:05 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id ol6si35272808icb.74.2014.06.11.15.54.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 15:54:05 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id tr6so430621ieb.15
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:54:05 -0700 (PDT)
Date: Wed, 11 Jun 2014 15:54:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
In-Reply-To: <alpine.DEB.2.10.1406110852280.7977@gentwo.org>
Message-ID: <alpine.DEB.2.02.1406111553430.27885@chino.kir.corp.google.com>
References: <20140608181436.17de69ac@redhat.com> <CAE9FiQXpUbAOinEK-1PSFyGKqpC_FHN0sjP0xvD0ChrXR5GdAw@mail.gmail.com> <20140609150353.75eff02b@redhat.com> <CAE9FiQUWZxvCS82cH=n-NF+nhTQ83J+7M3gHdXGu2S1Qk3xL_g@mail.gmail.com> <20140611092337.35794bc0@redhat.com>
 <alpine.DEB.2.10.1406110852280.7977@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, 11 Jun 2014, Christoph Lameter wrote:

> > > The zone should not cross the 8M boundary?
> >
> > Yes, but the question is: why?
> 
> zones need to be aligned so that the huge pages order and other page
> orders allocated from the page allocator are at their "natural alignment".
> Otherwise huge pages cannot be mapped properly and various I/O devices
> may encounter issues if they rely on the natural alignment.
> 

Any reason not to align to HUGETLB_PAGE_ORDER on x86 instead of 
ZONE_ALIGN?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
