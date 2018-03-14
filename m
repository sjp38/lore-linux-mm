Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6C86B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:00:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g199so1573104qke.18
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:00:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g5si1754420qkc.463.2018.03.14.01.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 01:00:45 -0700 (PDT)
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
 <ec90ed75-2810-bcc3-8439-8dc85a6b46ac@redhat.com>
 <20180309200017.GR1060@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <f71b583f-2b66-e9ed-b08b-fddff228a5a7@redhat.com>
Date: Wed, 14 Mar 2018 09:00:36 +0100
MIME-Version: 1.0
In-Reply-To: <20180309200017.GR1060@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On 03/09/2018 09:00 PM, Ram Pai wrote:
> On Fri, Mar 09, 2018 at 12:04:49PM +0100, Florian Weimer wrote:
>> On 03/09/2018 09:12 AM, Ram Pai wrote:
>>> Once an address range is associated with an allocated pkey, it cannot be
>>> reverted back to key-0. There is no valid reason for the above behavior.
>>
>> mprotect without a key does not necessarily use key 0, e.g. if
>> protection keys are used to emulate page protection flag combination
>> which is not directly supported by the hardware.
>>
>> Therefore, it seems to me that filtering out non-allocated keys is
>> the right thing to do.
> 
> I am not sure, what you mean. Do you agree with the patch or otherwise?

I think it's inconsistent to make key 0 allocated, but not the key which 
is used for PROT_EXEC emulation, which is still reserved.  Even if you 
change the key 0 behavior, it is still not possible to emulate mprotect 
behavior faithfully with an allocated key.

Thanks,
Florian
