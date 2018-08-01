Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 519126B0269
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 06:35:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d22-v6so2982467pfn.3
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 03:35:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o88-v6sor4730188pfa.77.2018.08.01.03.35.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 03:35:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c03fd1ca-0169-4492-7d6f-2df7a91bff5e@gmail.com>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <30ee6c72-dc90-275a-8e23-54221f393cb0@virtuozzo.com> <c03fd1ca-0169-4492-7d6f-2df7a91bff5e@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 1 Aug 2018 12:34:54 +0200
Message-ID: <CACT4Y+bLbDunoz+0qB=atbQXJ9Gu3N6+UXPwNnqMbq5RyZu1mQ@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, Network Development <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Dave Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Wed, Aug 1, 2018 at 12:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On 08/01/2018 02:03 AM, Andrey Ryabinin wrote:
>
>> I can't think of any advantage in not having the constructor.
>
> I can't see any advantage adding another indirect call,
> in RETPOLINE world.

Can you please elaborate what's the problem here?
If slab ctor call have RETPOLINE, then using ctors more does not
introduce any security problems and they are not _that_ slow.
If slab ctors are not protected, then we have problem that needs to be
fixed already.
What am I missing?
