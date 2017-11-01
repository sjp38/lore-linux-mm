Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 390936B0268
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:07:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b79so3189227pfk.9
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:07:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d17si1834982pge.191.2017.11.01.14.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 14:07:00 -0700 (PDT)
Subject: Re: [PATCH 21/23] x86, pcid, kaiser: allow flushing for future ASID
 switches
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223224.B9F5D5CA@viggo.jf.intel.com>
 <CALCETrUVC4KMPLNzs1mH=sGs9W9-HtajHAHOtOv0-LaT6uNb+g@mail.gmail.com>
 <38b34f81-3adb-98c5-c482-0d53b9155d3b@linux.intel.com>
 <CALCETrUSUYz8NcTz4aWkdCSo1dQh02QpYyLkWn=ScXoGH2vL1Q@mail.gmail.com>
 <5bc39561-b65e-82fd-3218-d91a4d22613a@linux.intel.com>
 <CALCETrUecDLRTdQBERrzk4nuS-fGFg0USkWRXfRMGw1fxYRP7w@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <233ff2e6-92a8-d0e6-d456-7e71991f6aef@linux.intel.com>
Date: Wed, 1 Nov 2017 14:06:59 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrUecDLRTdQBERrzk4nuS-fGFg0USkWRXfRMGw1fxYRP7w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/01/2017 02:04 PM, Andy Lutomirski wrote:
> Aha!  That wasn't at all clear to me from the changelog.  Can I make a
> totally different suggestion?  Add a new function
> __flush_tlb_one_kernel() and use it for kernel addresses. 

I'll look into this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
