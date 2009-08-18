Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5055A6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 11:48:09 -0400 (EDT)
Message-Id: <4A8AE95C020000780001055F@vpn.id2.novell.com>
Date: Tue, 18 Aug 2009 16:48:12 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] replace various uses of num_physpages by
	 totalram_pages
References: <4A8AE6280200007800010539@vpn.id2.novell.com>
 <20090818153815.GA11913@elte.hu>
In-Reply-To: <20090818153815.GA11913@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>> Ingo Molnar <mingo@elte.hu> 18.08.09 17:38 >>>
>
>* Jan Beulich <JBeulich@novell.com> wrote:
>
>> Sizing of memory allocations shouldn't depend on the number of=20
>> physical pages found in a system, as that generally includes=20
>> (perhaps a huge amount of) non-RAM pages. The amount of what=20
>> actually is usable as storage should instead be used as a basis=20
>> here.
>>=20
>> Some of the calculations (i.e. those not intending to use high=20
>> memory) should likely even use (totalram_pages -=20
>> totalhigh_pages).
>>=20
>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
>> Acked-by: Rusty Russell <rusty@rustcorp.com.au>
>>=20
>> ---
>>  arch/x86/kernel/microcode_core.c  |    4 ++--
>
>Acked-by: Ingo Molnar <mingo@elte.hu>
>
>Just curious: how did you find this bug? Did you find this by=20
>experiencing problems on a system with a lot of declared non-RAM=20
>memory?

Actually, I noticed this on Xen (non-pv-ops) when booting a domain with
a sufficiently large initial balloon. Under that condition, booting would
frequently fail due to various table sizes being calculated way too large.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
