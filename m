Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED636B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:40:09 -0400 (EDT)
Received: by vws4 with SMTP id 4so970309vws.14
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 13:40:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308169466.15617.378.camel@calx>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
	<1308089140.15617.221.camel@calx>
	<20110615201202.GB19593@Chamillionaire.breakpoint.cc>
	<1308169466.15617.378.camel@calx>
Date: Wed, 15 Jun 2011 23:40:05 +0300
Message-ID: <BANLkTi=QG3ywRhSx=npioJx-d=yyf=o29A@mail.gmail.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org

On Wed, Jun 15, 2011 at 11:24 PM, Matt Mackall <mpm@selenic.com> wrote:
> On Wed, 2011-06-15 at 22:12 +0200, Sebastian Andrzej Siewior wrote:
>> * Matt Mackall | 2011-06-14 17:05:40 [-0500]:
>>
>> >Ok, so you claim that ARCH_KMALLOC_MINALIGN is not set on some
>> >architectures, and thus SLOB does the wrong thing.
>> >
>> >Doesn't that rather obviously mean that the affected architectures
>> >should define ARCH_KMALLOC_MINALIGN? Because, well, they have an
>> >"architecture-specific minimum kmalloc alignment"?
>>
>> nope, if nothing is defined SLOB asumes that alignment of long is the way
>> go. Unfortunately alignment of u64 maybe larger than of u32.
>
> I understand that. I guess we have a different idea of what constitutes
> "architecture-specific" and what constitutes "normal".
>
> But I guess I can be persuaded that most architectures now expect 64-bit
> alignment of u64s.

Changing the alignment for everyone is likely to cause less problems
in the future. Matt, are there any practical reasons why we shouldn't
do that?

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
