Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21DA84408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 17:30:49 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q1so8494707qkb.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 14:30:49 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id h66si1233074qkc.291.2017.07.13.14.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 14:30:48 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id w12so7735616qta.2
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 14:30:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170713203704.GA5538@ram.oc3035372033.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-15-git-send-email-linuxram@us.ibm.com> <20170712132825.2a37e2e9@firefly.ozlabs.ibm.com>
 <20170713074500.GF5525@ram.oc3035372033.ibm.com> <20170713203704.GA5538@ram.oc3035372033.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 14 Jul 2017 07:30:46 +1000
Message-ID: <CAKTCnzkUQRVGrJyWwQM-SQGTxENzoYVPWLMWBUruKpb8t5Jnkg@mail.gmail.com>
Subject: Re: [RFC v5 14/38] powerpc: initial plumbing for key management
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-kselftest@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Haren Myneni/Beaverton/IBM <hbabu@us.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Ingo Molnar <mingo@redhat.com>

On Fri, Jul 14, 2017 at 6:37 AM, Ram Pai <linuxram@us.ibm.com> wrote:
> On Thu, Jul 13, 2017 at 12:45:00AM -0700, Ram Pai wrote:
>> On Wed, Jul 12, 2017 at 01:28:25PM +1000, Balbir Singh wrote:
>> > On Wed,  5 Jul 2017 14:21:51 -0700
>> > Ram Pai <linuxram@us.ibm.com> wrote:
>> >
>> > > Initial plumbing to manage all the keys supported by the
>> > > hardware.
>> > >
>> > > Total 32 keys are supported on powerpc. However pkey 0,1
>> > > and 31 are reserved. So effectively we have 29 pkeys.
>> > >
>> > > This patch keeps track of reserved keys, allocated  keys
>> > > and keys that are currently free.
>> >
>> > It looks like this patch will only work in guest mode?
>> > Is that an assumption we've made? What happens if I use
>> > keys when running in hypervisor mode?
>>
>> It works in supervisor mode, as a guest aswell as a bare-metal
>> kernel. Whatever needs to be done in hypervisor mode
>> is already there in power-kvm.
>
> I realize i did not answer your question accurately...
> "What happens if I use keys when running in hypervisor mode?"
>
> Its not clear what happens. As far as I can tell the MMU does
> not check key violation when in hypervisor mode. So effectively
> I think, keys are ineffective when in hypervisor mode.

keys are honored in hypervisor mode. I was just
stating that we need a mechanism used by the hypervisor
to partition the key space between guests and hypervisor.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
