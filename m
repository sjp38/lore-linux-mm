Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA9ED6B06C7
	for <linux-mm@kvack.org>; Sat, 19 May 2018 01:12:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c73-v6so9075252qke.2
        for <linux-mm@kvack.org>; Fri, 18 May 2018 22:12:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g28-v6si9098399qtf.255.2018.05.18.22.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 22:12:23 -0700 (PDT)
Subject: Re: pkeys on POWER: Access rights not reset on execve
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
 <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <d886e425-71fc-e203-e22d-7e07552c91c4@redhat.com>
Date: Sat, 19 May 2018 07:12:19 +0200
MIME-Version: 1.0
In-Reply-To: <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>

On 05/19/2018 03:19 AM, Ram Pai wrote:

>> New AMR value (PID 112291, before execl): 0x0c00000000000000
>> AMR (PID 112291): 0x0c00000000000000

The issue is here.  The second line is after the execl (printed from the 
start of main), and the AMR value is not reset to zero.

>> Allocated key (PID 112291): 2
>>
>> I think this is a real bug and needs to be fixed even if the
>> defaults are kept as-is (see the other thread).
> 
> The issue you may be talking about here is that  --
> 
> "when you set the AMR register to 0xffffffffffffffff, it
> just sets it to 0x0c00000000000000."
> 
> To me it looks like, exec/fork are not related to the issue.
> Or are they also somehow connected to the issue?

Yes, this is the other issue.  It is not really important here.

Thanks,
Florian
