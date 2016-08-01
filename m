Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF6EE6B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:58:11 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so248611607pac.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:58:11 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id a90si35457738pfk.184.2016.08.01.07.58.11
        for <linux-mm@kvack.org>;
        Mon, 01 Aug 2016 07:58:11 -0700 (PDT)
Subject: Re: [PATCH 08/10] x86, pkeys: default to a restrictive init PKRU
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
 <20160729163021.F3C25D4A@viggo.jf.intel.com>
 <cd74ae8b-36e4-a397-e36f-fe3d4281d400@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <579F6380.2070600@sr71.net>
Date: Mon, 1 Aug 2016 07:58:08 -0700
MIME-Version: 1.0
In-Reply-To: <cd74ae8b-36e4-a397-e36f-fe3d4281d400@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, dave.hansen@linux.intel.com, arnd@arndb.de

On 08/01/2016 07:42 AM, Vlastimil Babka wrote:
> On 07/29/2016 06:30 PM, Dave Hansen wrote:
>> This does not cause any practical problems with applications
>> using protection keys because we require them to specify initial
>> permissions for each key when it is allocated, which override the
>> restrictive default.
> 
> Here you mean the init_access_rights parameter of pkey_alloc()? So will
> children of fork() after that pkey_alloc() inherit the new value or go
> default?

Hi Vlastimil,

Yes, exactly, the initial permissions are provided via pkey_alloc()'s
'init_access_rights' argument.

Do you mean fork() or clone()?  In both cases, we actually copy the FPU
state from the parent, so children always inherit the state from their
parent which contains the permissions set by the parent's calls to
pkey_alloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
