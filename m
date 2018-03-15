Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F37E6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:50:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j12so3535987pff.18
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:50:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q4-v6si4344273plr.365.2018.03.15.10.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 10:50:01 -0700 (PDT)
Subject: Re: [PATCH v3] x86: treat pkey-0 special
References: <1521061214-22385-1-git-send-email-linuxram@us.ibm.com>
 <alpine.DEB.2.21.1803151039430.1525@nanos.tec.linutronix.de>
 <f5ef79ef-122a-e0a3-9b8e-d49c33f4a417@intel.com>
 <20180315172129.GD1060@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2bf8e659-5a8d-a2d5-ea52-e4d395ea2201@intel.com>
Date: Thu, 15 Mar 2018 10:31:51 -0700
MIME-Version: 1.0
In-Reply-To: <20180315172129.GD1060@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On 03/15/2018 10:21 AM, Ram Pai wrote:
> On Thu, Mar 15, 2018 at 08:55:31AM -0700, Dave Hansen wrote:
>> On 03/15/2018 02:46 AM, Thomas Gleixner wrote:
>>>> +	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
>>> Why this extra check? mm_pkey_is_allocated(mm, 0) should not return true
>>> ever. If it does, then this wants to be fixed.
>> I was thinking that we _do_ actually want it to seem allocated.  It just
>> get "allocated" implicitly when an mm is created.  I think that will
>> simplify the code if we avoid treating it specially in as many places as
>> possible.
> I think, the logic that makes pkey-0 special must to go
> in arch-neutral code.   How about checking for pkey-0 in sys_pkey_free()
> itself?

This is for protection against shooting yourself in the foot?  Yes, that
can go in sys_pkey_free().

Does this need manpage and/or selftests updates?
