Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3C956B026B
	for <linux-mm@kvack.org>; Mon,  7 May 2018 05:48:23 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f1-v6so20944957qtm.12
        for <linux-mm@kvack.org>; Mon, 07 May 2018 02:48:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u36-v6si1753707qtc.6.2018.05.07.02.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 02:48:23 -0700 (PDT)
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
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <927c8325-4c98-d7af-b921-6aafcf8fe992@redhat.com>
Date: Mon, 7 May 2018 11:48:20 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, linuxram@us.ibm.com
Cc: Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, ".linuxppc-dev"@lists.ozlabs.org

On 05/03/2018 06:05 AM, Andy Lutomirski wrote:
> On Wed, May 2, 2018 at 7:11 PM Ram Pai <linuxram@us.ibm.com> wrote:
> 
>> On Wed, May 02, 2018 at 09:23:49PM +0000, Andy Lutomirski wrote:
>>>
>>>> If I recall correctly, the POWER maintainer did express a strong
> desire
>>>> back then for (what is, I believe) their current semantics, which my
>>>> PKEY_ALLOC_SIGNALINHERIT patch implements for x86, too.
>>>
>>> Ram, I really really don't like the POWER semantics.  Can you give some
>>> justification for them?  Does POWER at least have an atomic way for
>>> userspace to modify just the key it wants to modify or, even better,
>>> special load and store instructions to use alternate keys?
> 
>> I wouldn't call it POWER semantics. The way I implemented it on power
>> lead to the semantics, given that nothing was explicitly stated
>> about how the semantics should work within a signal handler.
> 
> I think that this is further evidence that we should introduce a new
> pkey_alloc() mode and deprecate the old.  To the extent possible, this
> thing should work the same way on x86 and POWER.

Do you propose to change POWER or to change x86?

Thanks,
Florian
