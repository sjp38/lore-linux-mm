Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07C566B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 17:08:19 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y9so11709343qki.23
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:08:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h6-v6si9959089qvo.152.2018.05.02.14.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 14:08:18 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <63086671-3603-1a79-d1a0-63913855456a@intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <a42f040c-babf-f1d3-80d2-587afe17b742@redhat.com>
Date: Wed, 2 May 2018 23:08:15 +0200
MIME-Version: 1.0
In-Reply-To: <63086671-3603-1a79-d1a0-63913855456a@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: linuxram@us.ibm.com, Andy Lutomirski <luto@kernel.org>

On 05/02/2018 05:28 PM, Dave Hansen wrote:
> The other option here that I think we discussed in the past was to have
> an*explicit*  signal PKRU value.  That way, we can be restrictive by
> default but allow overrides for special cases like you have.

That's the patch I posted before (with PKEY_ALLOC_SETSIGNAL).  I'm 
afraid we are going in circles.

Thanks,
Florian
