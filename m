Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6906B003D
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 11:45:50 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so2313718qaq.39
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:45:50 -0800 (PST)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id ib7si4529397qcb.81.2014.01.16.08.45.49
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 08:45:49 -0800 (PST)
Date: Thu, 16 Jan 2014 10:45:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 2/9] mm: slub: abstract out double cmpxchg option
In-Reply-To: <52D5AEF7.6020707@sr71.net>
Message-ID: <alpine.DEB.2.10.1401161045180.29778@nuc>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180046.C897727E@viggo.jf.intel.com> <alpine.DEB.2.10.1401141346310.19618@nuc> <52D5AEF7.6020707@sr71.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> On 01/14/2014 11:49 AM, Christoph Lameter wrote:
> > On Tue, 14 Jan 2014, Dave Hansen wrote:
> >> I found this useful to have in my testing.  I would like to have
> >> it available for a bit, at least until other folks have had a
> >> chance to do some testing with it.
> >
> > I dont really see the point of this patch since we already have
> > CONFIG_HAVE_ALIGNED_STRUCT_PAGE to play with.
>
> With the current code, if you wanted to turn off the double-cmpxchg abd
> get a 56-byte 'struct page' how would you do it?  Can you do it with a
> .config, or do you need to hack the code?

Remove HAVE_ALIGNED_STRUCT_PAGE from a Kconfig file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
