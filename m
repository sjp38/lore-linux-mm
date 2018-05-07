Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0C86B0010
	for <linux-mm@kvack.org>; Mon,  7 May 2018 05:47:13 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t24-v6so20933965qtn.7
        for <linux-mm@kvack.org>; Mon, 07 May 2018 02:47:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i6-v6si2934621qvj.65.2018.05.07.02.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 02:47:12 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <63086671-3603-1a79-d1a0-63913855456a@intel.com>
 <a42f040c-babf-f1d3-80d2-587afe17b742@redhat.com>
 <4bbb5f76-f2ed-c2b7-9b4c-079a6ddf4da2@intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <3cc009e7-84ff-56b4-2751-686772036676@redhat.com>
Date: Mon, 7 May 2018 11:47:10 +0200
MIME-Version: 1.0
In-Reply-To: <4bbb5f76-f2ed-c2b7-9b4c-079a6ddf4da2@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: linuxram@us.ibm.com, Andy Lutomirski <luto@kernel.org>

On 05/03/2018 12:03 AM, Dave Hansen wrote:
> On 05/02/2018 02:08 PM, Florian Weimer wrote:
>> On 05/02/2018 05:28 PM, Dave Hansen wrote:
>>> The other option here that I think we discussed in the past was to have
>>> an*explicit*A  signal PKRU value.A  That way, we can be restrictive by
>>> default but allow overrides for special cases like you have.
>>
>> That's the patch I posted before (with PKEY_ALLOC_SETSIGNAL).A  I'm
>> afraid we are going in circles.
> 
> Could you remind us why you abandoned that approach and its relative
> merits versus this new approach?

Ram argued for the PKEY_ALLOC_SIGNALINHERIT and no one else objected or 
was interested at the time.  I may have misread the consensus.

I'm not sure what do here.  I tried to submit patches for the two 
suggested approaches, and each one resulted in suggests to implement the 
other semantics instead.

Thanks,
Florian
