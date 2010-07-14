Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7E6816B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 05:07:47 -0400 (EDT)
Received: by bwz9 with SMTP id 9so4726461bwz.14
        for <linux-mm@kvack.org>; Wed, 14 Jul 2010 02:07:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1279058027.936.236.camel@calx>
References: <1278756333-6850-1-git-send-email-lliubbo@gmail.com>
	<AANLkTikMcPcldBh_uVKxrH7rEIUju3Y_3X2jLi9jw2Vs@mail.gmail.com>
	<1279058027.936.236.camel@calx>
Date: Wed, 14 Jul 2010 12:07:44 +0300
Message-ID: <AANLkTil-sv82zjR7yJr_3nZ0QBO_8Jwj_FO0iFubwe2s@mail.gmail.com>
Subject: Re: [PATCH] slob_free:free objects to their own list
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 14, 2010 at 12:53 AM, Matt Mackall <mpm@selenic.com> wrote:
> On Tue, 2010-07-13 at 20:52 +0300, Pekka Enberg wrote:
>> Hi Bob,
>>
>> [ Please CC me on SLOB patches. You can use the 'scripts/get_maintainer.=
pl'
>> =A0 script to figure out automatically who to CC on your patches. ]
>>
>> On Sat, Jul 10, 2010 at 1:05 PM, Bob Liu <lliubbo@gmail.com> wrote:
>> > slob has alloced smaller objects from their own list in reduce
>> > overall external fragmentation and increase repeatability,
>> > free to their own list also.
>> >
>> > Signed-off-by: Bob Liu <lliubbo@gmail.com>
>>
>> The patch looks sane to me. Matt, does it look OK to you as well?
>
> Yep, this should be a marginal improvement.
>
> Acked-by: Matt Mackall <mpm@selenic.com>

Great! Bob, if you could provide the /proc/meminfo numbers for the
patch description, I'd be more than happy to merge this.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
