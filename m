Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95E156B0618
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 12:14:56 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 18-v6so16973168pgn.4
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 09:14:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h188-v6si4945997pfg.129.2018.11.08.09.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 09:14:55 -0800 (PST)
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
 <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
 <87bm6zaa04.fsf@oldenburg.str.redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
Date: Thu, 8 Nov 2018 09:14:54 -0800
MIME-Version: 1.0
In-Reply-To: <87bm6zaa04.fsf@oldenburg.str.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com

On 11/8/18 7:01 AM, Florian Weimer wrote:
> Ideally, PKEY_DISABLE_READ | PKEY_DISABLE_WRITE and PKEY_DISABLE_READ |
> PKEY_DISABLE_ACCESS would be treated as PKEY_DISABLE_ACCESS both, and a
> line PKEY_DISABLE_READ would result in an EINVAL failure.

Sounds reasonable to me.

I don't see any urgency to do this right now.  It could easily go in
alongside the ppc patches when those get merged.  The only thing I'd
suggest is that we make it something slightly higher than 0x4.  It'll
make the code easier to deal with in the kernel if we have the ABI and
the hardware mirror each other, and if we pick 0x4 in the ABI for
PKEY_DISABLE_READ, it might get messy if the harware choose 0x4 for
PKEY_DISABLE_EXECUTE or something.

So, let's make it 0x80 or something on x86 at least.

Also, I'll be happy to review and ack the patch to do this, but I'd
expect the ppc guys (hi Ram!) to actually put it together.
