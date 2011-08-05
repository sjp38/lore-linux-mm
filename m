Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CB4506B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 22:57:07 -0400 (EDT)
Received: by qwa26 with SMTP id 26so318232qwa.14
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 19:57:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d0584e86-34f6-46cc-a78e-c1e31ed7cb9f@default>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-2-git-send-email-lliubbo@gmail.com>
	<20110804075730.GF31039@tiehlicka.suse.cz>
	<20110804090017.GI31039@tiehlicka.suse.cz>
	<CAA_GA1f8B9uPszGecYd=DiuAOCqo0AXkFca_=5jEGRczGia5ZA@mail.gmail.com>
	<d0584e86-34f6-46cc-a78e-c1e31ed7cb9f@default>
Date: Fri, 5 Aug 2011 10:57:05 +0800
Message-ID: <CAA_GA1cQBZ+3qyJeVgU6UcHax5TCGwNtjEnoWhq9w+LFnM9C7w@mail.gmail.com>
Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com

On Fri, Aug 5, 2011 at 10:45 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> > I am fairly sure that the failed allocation is handled gracefully
>> > through the remainder of the frontswap code, but will re-audit to
>> > confirm. =C2=A0A warning might be nice though.
>>
>> There is a place i think maybe have problem.
>> function __frontswap_flush_area() in file frontswap.c called
>> memset(sis->frontswap_map, .., ..);
>> But if frontswap_map allocation fail there is a null pointer access ?
>
> Good catch!
>
> I'll fix that when I submit a frontswap update in a few days.
>

Would you please add current patch to you frontswap update series ?
So I needn't to send a Version 2 separately with only drop the
allocation failed handler.
Thanks.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
