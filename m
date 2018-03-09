Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92B936B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 03:37:06 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id s62so1359985vke.4
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 00:37:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor205498vkb.142.2018.03.09.00.37.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 00:37:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 9 Mar 2018 19:37:04 +1100
Message-ID: <CAKTCnz=QrNoG0wdTZRJqmYfFOZmq2czZ4x8v1e=ouNx2Y8D6wg@mail.gmail.com>
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Haren Myneni/Beaverton/IBM <hbabu@us.ibm.com>, Michal Hocko <mhocko@kernel.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On Fri, Mar 9, 2018 at 7:12 PM, Ram Pai <linuxram@us.ibm.com> wrote:
> Once an address range is associated with an allocated pkey, it cannot be
> reverted back to key-0. There is no valid reason for the above behavior.  On
> the contrary applications need the ability to do so.
>
> The patch relaxes the restriction.

I looked at the code and my observation was going to be that we need
to change mm_pkey_is_allocated. I still fail to understand what
happens if pkey 0 is reserved? What is the default key is it the first
available key? Assuming 0 is the default key may work and seems to
work, but I am sure its mostly by accident. It would be nice, if we
could have  a notion of the default key. I don't like the special
meaning given to key 0 here. Remember on powerpc if 0 is reserved and
UAMOR/AMOR does not allow modification because it's reserved, setting
0 will still fail

Balbir
