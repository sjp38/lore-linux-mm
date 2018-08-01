Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34BB66B0008
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 12:47:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d12-v6so11143585pgv.12
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 09:47:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z24-v6sor4713529pgn.109.2018.08.01.09.47.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 09:47:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <bf435a04-b689-ec5a-f5df-f47807b43316@gmail.com>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <30ee6c72-dc90-275a-8e23-54221f393cb0@virtuozzo.com> <c03fd1ca-0169-4492-7d6f-2df7a91bff5e@gmail.com>
 <CACT4Y+bLbDunoz+0qB=atbQXJ9Gu3N6+UXPwNnqMbq5RyZu1mQ@mail.gmail.com>
 <cf751136-c459-853a-0210-abf16f54ad17@gmail.com> <CACT4Y+b6aCHMTQD21fSf2AMZoH5g8p-FuCVHviMLF00uFV+zGg@mail.gmail.com>
 <01000164f60f3f12-b1253c6e-ee57-49fc-aed8-0944ab4fd7a2-000000@email.amazonses.com>
 <CANn89i+KtwtLvSw1c=Ux8okKP+XyMxzYbuKhYb2qhYeMw=NTzg@mail.gmail.com>
 <01000164f64bd525-be13e04f-18a9-4f7f-a44b-0c0fcec33b71-000000@email.amazonses.com>
 <bf435a04-b689-ec5a-f5df-f47807b43316@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 1 Aug 2018 18:47:26 +0200
Message-ID: <CACT4Y+akncPCAZ2pUX3xEpUPELQAei1XzYByB8Dohfz-Ve0k5w@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christopher Lameter <cl@linux.com>, Eric Dumazet <edumazet@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Wed, Aug 1, 2018 at 6:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On 08/01/2018 09:22 AM, Christopher Lameter wrote:
>> On Wed, 1 Aug 2018, Eric Dumazet wrote:
>>
>>> The idea of having a ctor() would only be a win if all the fields that
>>> can be initialized in the ctor are contiguous and fill an integral
>>> number of cache lines.
>>
>> Ok. Its reducing code size and makes the object status more consistent.
>> Isn't that enough?
>>
>
> Prove it ;)
>
> I yet have to seen actual numbers.

Proving with numbers is required for a claimed performance improvement
at the cost of code degradation/increase. For a win-win change there
is really nothing to prove.
