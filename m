Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF9896B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 00:11:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q6so10475015pgv.12
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 21:11:50 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b8-v6si408551pll.146.2018.03.26.21.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 21:11:49 -0700 (PDT)
Subject: Re: [PATCH 1/9] x86, pkeys: do not special case protection key 0
References: <20180323180903.33B17168@viggo.jf.intel.com>
 <20180323180905.B40984E6@viggo.jf.intel.com>
 <20180327022718.GD5743@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0f990ce6-0eac-bd77-18d8-e2e3fdd5fb43@intel.com>
Date: Mon, 26 Mar 2018 21:11:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180327022718.GD5743@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On 03/26/2018 07:27 PM, Ram Pai wrote:
>> This is a bit nicer than what Ram proposed because it is simpler
>> and removes special-casing for pkey 0.  On the other hand, it does
>> allow applciations to pkey_free() pkey-0, but that's just a silly
>> thing to do, so we are not going to protect against it.
> The more I think about this, the more I feel we are opening up a can
> of worms.  I am ok with a bad application, shooting itself in its feet.
> But I am worried about all the bug reports and support requests we
> will encounter when applications inadvertently shoot themselves 
> and blame it on the kernel.
> 
> a warning in dmesg logs indicating a free-of-pkey-0 can help deflect
> the blame from the kernel.

I think it's OK to leave it.  A legit, very careful app could decide not
to use pkey 0.  It might even be fun to write that in the selftests for
sheer entertainment value.

Although, it _could_ be a bit more debuggable than it is now.  A
tracepoint that dumps out the pkey that got faulted on along with the
PKRU value at fault time might be nice to have.  That's mildly difficult
to do from outside the app.
