Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7776B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 01:53:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b195-v6so11850735qkc.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 22:53:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f46-v6si2019002qtc.204.2018.06.07.22.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 22:53:54 -0700 (PDT)
Subject: Re: pkeys on POWER: Access rights not reset on execve
References: <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
 <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
 <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
 <20180604190229.GB10088@ram.oc3035372033.ibm.com>
 <30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
 <20180608023441.GA5573@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
Date: Fri, 8 Jun 2018 07:53:51 +0200
MIME-Version: 1.0
In-Reply-To: <20180608023441.GA5573@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On 06/08/2018 04:34 AM, Ram Pai wrote:
>>
>> So the remaining question at this point is whether the Intel
>> behavior (default-deny instead of default-allow) is preferable.
> 
> Florian, remind me what behavior needs to fixed?

See the other thread.  The Intel register equivalent to the AMR by 
default disallows access to yet-unallocated keys, so that threads which 
are created before key allocation do not magically gain access to a key 
allocated by another thread.

Thanks,
Florian
