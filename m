Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 961816B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:18:39 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id r10so236536pdi.6
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 14:18:39 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id vz4si1715668pac.209.2014.01.14.14.18.37
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 14:18:38 -0800 (PST)
Message-ID: <52D5B762.3090209@sr71.net>
Date: Tue, 14 Jan 2014 14:17:06 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/9] mm: page->pfmemalloc only used by slab/skb
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180051.0181E467@viggo.jf.intel.com> <alpine.DEB.2.10.1401141348130.19618@nuc>
In-Reply-To: <alpine.DEB.2.10.1401141348130.19618@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On 01/14/2014 11:49 AM, Christoph Lameter wrote:
> On Tue, 14 Jan 2014, Dave Hansen wrote:
>> page->pfmemalloc does not deserve a spot in 'struct page'.  It is
>> only used transiently _just_ after a page leaves the buddy
>> allocator.
> 
> Why would we need to do this if we are removing the cmpxchg_double?

Why do we need the patch?

'struct page' is a mess.  It's really hard to follow, and the space in
the definition is a limited resource.  We should not waste that space on
such a transient and unimportant value as pfmemalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
