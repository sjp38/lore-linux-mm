Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E160E6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 11:42:02 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ib6so32015328pad.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 08:42:02 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id s9si633790pay.67.2016.07.07.08.42.02
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 08:42:02 -0700 (PDT)
Subject: Re: [PATCH 1/9] x86, pkeys: add fault handling for PF_PK page fault
 bit
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124720.6E0DC397@viggo.jf.intel.com>
 <20160707144027.GX11498@techsingularity.net>
From: Dave Hansen <dave@sr71.net>
Message-ID: <577E7848.3060908@sr71.net>
Date: Thu, 7 Jul 2016 08:42:00 -0700
MIME-Version: 1.0
In-Reply-To: <20160707144027.GX11498@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On 07/07/2016 07:40 AM, Mel Gorman wrote:
> On Thu, Jul 07, 2016 at 05:47:20AM -0700, Dave Hansen wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>> PF_PK means that a memory access violated the protection key
>> access restrictions.  It is unconditionally an access_error()
>> because the permissions set on the VMA don't matter (the PKRU
>> value overrides it), and we never "resolve" PK faults (like
>> how a COW can "resolve write fault).
>>
>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> 
> An access fault gets propgated as SEGV_PKUERR. What happens if glibc
> does not recognise it?

It passes it through to the handler without any side-effects.  I don't
think it does anything differently with SEGV_* codes that it knows about
vs. unknown ones.  The only negative side-effect that I can think of is
that it won't have a nice error message for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
