Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 248C96B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:59:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u188so11519689pfb.6
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:59:04 -0700 (PDT)
Received: from osg.samsung.com (osg.samsung.com. [64.30.133.232])
        by mx.google.com with ESMTP id e6si10276936pgt.198.2018.03.26.10.59.02
        for <linux-mm@kvack.org>;
        Mon, 26 Mar 2018 10:59:02 -0700 (PDT)
Subject: Re: [PATCH 1/9] x86, pkeys: do not special case protection key 0
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172722.8CC08307@viggo.jf.intel.com>
 <9c2de5f6-d9e2-3647-7aa8-86102e9fa6c3@kernel.org>
 <b54257c2-138c-7ac9-8176-0dc4868093ef@intel.com>
From: Shuah Khan <shuahkh@osg.samsung.com>
Message-ID: <19a54db9-b0bd-5661-de2a-c5ee76e733d9@osg.samsung.com>
Date: Mon, 26 Mar 2018 11:58:59 -0600
MIME-Version: 1.0
In-Reply-To: <b54257c2-138c-7ac9-8176-0dc4868093ef@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Shuah Khan <shuah@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, stable@kernel.org, linuxram@us.ibm.com, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, Shuah Khan <shuahkh@osg.samsung.com>Shuah Khan <shuahkh@osg.samsung.com>

On 03/26/2018 11:53 AM, Dave Hansen wrote:
> On 03/26/2018 10:47 AM, Shuah Khan wrote:
>>
>> Also what happens "pkey_free() pkey-0" - can you elaborate more on that
>> "silliness consequences"
> 
> It's just what happens if you free any other pkey that is in use: it
> might get reallocated later.  The most likely scenario is that you will
> get pkey-0 back from pkey_alloc(), you will set an access-disable or
> write-disable bit in PKRU for it, and your next stack access will SIGSEGV.
> 

Thanks. This will good information to include in the commit log.

-- Shuah
