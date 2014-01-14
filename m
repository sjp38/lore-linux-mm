Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 75AA16B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:42:49 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f35so297764yha.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:42:49 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id s22si2419861yha.51.2014.01.14.13.42.43
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 13:42:43 -0800 (PST)
Message-ID: <52D5AEF7.6020707@sr71.net>
Date: Tue, 14 Jan 2014 13:41:11 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] mm: slub: abstract out double cmpxchg option
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180046.C897727E@viggo.jf.intel.com> <alpine.DEB.2.10.1401141346310.19618@nuc>
In-Reply-To: <alpine.DEB.2.10.1401141346310.19618@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On 01/14/2014 11:49 AM, Christoph Lameter wrote:
> On Tue, 14 Jan 2014, Dave Hansen wrote:
>> I found this useful to have in my testing.  I would like to have
>> it available for a bit, at least until other folks have had a
>> chance to do some testing with it.
> 
> I dont really see the point of this patch since we already have
> CONFIG_HAVE_ALIGNED_STRUCT_PAGE to play with.

With the current code, if you wanted to turn off the double-cmpxchg abd
get a 56-byte 'struct page' how would you do it?  Can you do it with a
.config, or do you need to hack the code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
