Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B77D16B0345
	for <linux-mm@kvack.org>; Wed, 16 May 2018 13:02:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a6-v6so857203pll.22
        for <linux-mm@kvack.org>; Wed, 16 May 2018 10:02:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 38-v6si3002591plc.446.2018.05.16.10.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 10:02:01 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
 <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
 <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <20180503021058.GA5670@ram.oc3035372033.ibm.com>
 <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com>
 <927c8325-4c98-d7af-b921-6aafcf8fe992@redhat.com>
 <CALCETrX46wR_MDW=m9SVm=ejQmPAmD3+2oC3iapf75bPhnEAWQ@mail.gmail.com>
 <314e1a48-db94-9b37-8793-a95a2082c9e2@redhat.com>
 <CALCETrUGjN8mhOaLqGcau-pPKm9TQW8k05hZrh52prRNdC5yQQ@mail.gmail.com>
 <008010c1-20a1-c307-25ac-8a69d672d031@redhat.com>
 <E77C6E12-EF2A-435A-AAD4-1554459606F1@amacapital.net>
 <c727a0da-dd5b-4ca2-375c-773ec550ab25@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <36f7fb7b-9b78-cb41-c59a-8346b8d7509b@intel.com>
Date: Wed, 16 May 2018 10:01:59 -0700
MIME-Version: 1.0
In-Reply-To: <c727a0da-dd5b-4ca2-375c-773ec550ab25@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, linuxram@us.ibm.com, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On 05/14/2018 08:34 AM, Florian Weimer wrote:
>>> The initial PKRU value can currently be configured by the system
>>> administrator.A  I fear this approach has too many moving parts to be
>>> viable.
>>
>> Honestly, I think we should drop that option. I dona??t see how we can
>> expect an administrator to do this usefully.
> 
> I don't disagreea??it makes things way less predictable in practice.

I originally put that thing in there to make Andy happy with the initial
permissions, and give us a way to back it out if something went wrong.
I have no objections to removing it either.
