Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2DF4402ED
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 14:25:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r88so62045pfi.23
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 11:25:14 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h14si1495660pfk.18.2017.11.16.11.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 11:25:13 -0800 (PST)
Subject: Re: [PATCH 23/30] x86, kaiser: use PCID feature to make user and
 kernel switches faster
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193150.1E736CE0@viggo.jf.intel.com>
 <20171116191931.GC2344@redhat.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <157fa017-16d8-af5b-f6c3-77794c0546cf@linux.intel.com>
Date: Thu, 16 Nov 2017 11:25:10 -0800
MIME-Version: 1.0
In-Reply-To: <20171116191931.GC2344@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/16/2017 11:19 AM, Andrea Arcangeli wrote:
> On Fri, Nov 10, 2017 at 11:31:50AM -0800, Dave Hansen wrote:
>> Hugh Dickins also points out that PCIDs really have two distinct
>> use-cases in the context of KAISER.  The first way they can be used
> I don't see why you try to retain such a minor optimization for newer
> Intel chips when at the same you prevent KAISER to run with good
> performance on older Intel chips like SandyBridge/IvyBridge which
> would create a major performance regression for those two.

This was more straightforward to do.

The other way requires having *TWO* PCID modes.  So, we need to
disambiguate the two modes in the existing infrastructure in addition to
adding KAISER.

Had I gone and done that, my fear was that we would be left with no
usable PCIDs on *any* hardware.  So, this was easier, I went and did it
first, and I'd love to see someone add support for PCIDs on those older
non-INVPCID systems.  "Someone" may even be me, but it'll be in v2.

Patches welcome before then. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
