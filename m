Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA946B0160
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:58:56 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id dc16so3102415qab.15
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 06:58:55 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id s49si30544860qgs.97.2014.06.11.06.58.54
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 06:58:55 -0700 (PDT)
Date: Wed, 11 Jun 2014 08:58:51 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
In-Reply-To: <20140611092337.35794bc0@redhat.com>
Message-ID: <alpine.DEB.2.10.1406110852280.7977@gentwo.org>
References: <20140608181436.17de69ac@redhat.com> <CAE9FiQXpUbAOinEK-1PSFyGKqpC_FHN0sjP0xvD0ChrXR5GdAw@mail.gmail.com> <20140609150353.75eff02b@redhat.com> <CAE9FiQUWZxvCS82cH=n-NF+nhTQ83J+7M3gHdXGu2S1Qk3xL_g@mail.gmail.com>
 <20140611092337.35794bc0@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, 11 Jun 2014, Luiz Capitulino wrote:

> > The zone should not cross the 8M boundary?
>
> Yes, but the question is: why?

zones need to be aligned so that the huge pages order and other page
orders allocated from the page allocator are at their "natural alignment".
Otherwise huge pages cannot be mapped properly and various I/O devices
may encounter issues if they rely on the natural alignment.

> My current thinking, after discussing this with David, is to just page
> align the memory range. This should fix the hyperv-triggered bug in 2.6.32
> and seems to be the right thing for upstream too.

You need to make sure that the page orders can be allocated at their
proper boundaries.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
