Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61EF26B06CB
	for <linux-mm@kvack.org>; Sat, 19 May 2018 01:26:20 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t24-v6so8661204qtn.7
        for <linux-mm@kvack.org>; Fri, 18 May 2018 22:26:20 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a9-v6si9026420qtk.205.2018.05.18.22.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 22:26:19 -0700 (PDT)
Subject: Re: pkeys on POWER: Access rights not reset on execve
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
 <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
 <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <b5875cbf-16f6-41cd-1f9e-cb94b0eb3a18@redhat.com>
Date: Sat, 19 May 2018 07:26:17 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, linuxram@us.ibm.com
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On 05/19/2018 03:50 AM, Andy Lutomirski wrote:
> Now another thread calls pkey_alloc(), so UAMR is asynchronously changed,
> and the thread will write zero to the relevant AMR bits.  If I understand
> correctly, this means that the decision to mask off unallocated keys via
> UAMR effectively forces the initial value of newly-allocated keys in other
> threads in the allocating process to be zero, whatever zero means.  (I
> didn't get far enough in the POWER docs to figure out what zero means.)  So

(Note that this belongs on the other thread, here I originally wanted to 
talk about the lack of reset of AMR to the default value on execve.)

I don't think UAMOR is updated asynchronously.  On pkey_alloc, it is 
only changed for the current thread, and future threads launched from 
it.  Existing threads are unaffected.  This still results in a 
programming model which is substantially different from x86.

> I don't think you're doing anyone any favors by making UAMR dynamic.

This is still true, I think.

Thanks,
Florian
