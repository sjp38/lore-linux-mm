Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E85C86B068D
	for <linux-mm@kvack.org>; Fri, 18 May 2018 17:13:34 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l47-v6so7862588qtk.21
        for <linux-mm@kvack.org>; Fri, 18 May 2018 14:13:34 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t5-v6si4994509qki.361.2018.05.18.14.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 14:13:34 -0700 (PDT)
Subject: Re: pkeys on POWER: Default AMR, UAMOR values
References: <36b98132-d87f-9f75-f1a9-feee36ec8ee6@redhat.com>
 <20180518174448.GE5479@ram.oc3035372033.ibm.com>
 <CALCETrV_wYPKHna8R2Bu19nsDqF2dJWarLLsyHxbcYD_AgYfPg@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <27e01118-be5c-5f90-78b2-56bb69d2ab95@redhat.com>
Date: Fri, 18 May 2018 23:13:30 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrV_wYPKHna8R2Bu19nsDqF2dJWarLLsyHxbcYD_AgYfPg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, linuxram@us.ibm.com
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On 05/18/2018 09:39 PM, Andy Lutomirski wrote:
> The difference is that x86 starts out with deny-all instead of allow-all.
> The POWER semantics make it very hard for a multithreaded program to
> meaningfully use protection keys to prevent accidental access to important
> memory.

And you can change access rights for unallocated keys (unallocated at 
thread start time, allocated later) on x86.  I have extended the 
misc/tst-pkeys test to verify that, and it passes on x86, but not on 
POWER, where the access rights are stuck.

I believe this is due to an incorrect UAMOR setting.

Thanks,
Florian
