Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f170.google.com (mail-gg0-f170.google.com [209.85.161.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4636B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 17:30:48 -0500 (EST)
Received: by mail-gg0-f170.google.com with SMTP id l4so1094188ggi.1
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 14:30:47 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id s6si12147486yho.14.2014.01.16.14.30.41
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 14:30:41 -0800 (PST)
Message-ID: <52D85D33.4080509@sr71.net>
Date: Thu, 16 Jan 2014 14:29:07 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 5/9] mm: rearrange struct page
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180055.21691733@viggo.jf.intel.com> <alpine.DEB.2.10.1401161233060.30036@nuc>
In-Reply-To: <alpine.DEB.2.10.1401161233060.30036@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On 01/16/2014 10:34 AM, Christoph Lameter wrote:
> On Tue, 14 Jan 2014, Dave Hansen wrote:
>> This makes it *MUCH* more clear how the first few fields of
>> 'struct page' get used by the slab allocators.
> 
> I think this adds to the confusion. What you want to know is which other
> fields overlap a certain field. After this patch you wont have that
> anymore.

Why does it matter *specifically* that "index shares space with
freelist", or that "mapping shares space with s_mem"?  No data is ever
handed off in those fields.

All that matters is that we know the _set_ of fields that gets reused,
and that we preserve the ones which *need* their contents preserved
(only flags and _count as far as I can tell).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
