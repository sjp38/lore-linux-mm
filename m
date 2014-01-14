Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 067876B0035
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 14:49:41 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id e16so85857qcx.21
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:49:41 -0800 (PST)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id q18si1793702qeu.82.2014.01.14.11.49.40
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 11:49:41 -0800 (PST)
Date: Tue, 14 Jan 2014 13:49:38 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 2/9] mm: slub: abstract out double cmpxchg option
In-Reply-To: <20140114180046.C897727E@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.10.1401141346310.19618@nuc>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180046.C897727E@viggo.jf.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> I found this useful to have in my testing.  I would like to have
> it available for a bit, at least until other folks have had a
> chance to do some testing with it.

I dont really see the point of this patch since we already have
CONFIG_HAVE_ALIGNED_STRUCT_PAGE to play with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
