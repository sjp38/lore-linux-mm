Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D1EB16B0277
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 10:17:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m18so2657796pgd.13
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 07:17:48 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m23si1024926pgc.800.2017.11.01.07.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 07:17:47 -0700 (PDT)
Subject: Re: [PATCH 21/23] x86, pcid, kaiser: allow flushing for future ASID
 switches
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223224.B9F5D5CA@viggo.jf.intel.com>
 <CALCETrUVC4KMPLNzs1mH=sGs9W9-HtajHAHOtOv0-LaT6uNb+g@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <38b34f81-3adb-98c5-c482-0d53b9155d3b@linux.intel.com>
Date: Wed, 1 Nov 2017 07:17:45 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrUVC4KMPLNzs1mH=sGs9W9-HtajHAHOtOv0-LaT6uNb+g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/01/2017 01:03 AM, Andy Lutomirski wrote:
>> This ensures that any futuee context switches will do a full flush
>> of the TLB so they pick up the changes.
> I'm convuced.  What was wrong with the old code?  I guess I just don't
> see what the problem is that is solved by this patch.

Instead of flushing *now* with INVPCID, this lets us flush *later* with
CR3.  It just hijacks the code that you already have that flushes CR3
when loading a new ASID by making all ASIDs look new in the future.

We have to load CR3 anyway, so we might as well just do this flush then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
