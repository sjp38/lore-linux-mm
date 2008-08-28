From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Definition of x86 _PAGE_SPECIAL and sharing _PAGE_UNUSED1
Date: Thu, 28 Aug 2008 10:32:30 +1000
References: <48B5A4B0.9050308@goop.org>
In-Reply-To: <48B5A4B0.9050308@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808281032.30594.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Ingo Molnar <mingo@elte.hu>, Hugh Dickens <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 28 August 2008 05:02, Jeremy Fitzhardinge wrote:
> _PAGE_SPECIAL is overloading _PAGE_UNUSED1.  Does it really leave
> _PAGE_UNUSED1 available for other uses, or does it become an exclusive
> user of that flag.  Under what circumstances can they be shared?
>
> arch/x86/mm/pageattr-test.c is now using _PAGE_UNUSED1 as the flag used
> to make sure that huge pages are shattered properly (previously it used
> _PAGE_GLOBAL).  Is that going to clash with _PAGE_SPECIAL?

Ah... pity it was hidden away there and not put into the include file.


> In other words, should we drop _PAGE_UNUSED1 altogether, or at least
> define how the its different users can coexist?

I don't feel strongly about it. But you should put your definition in
pgtable.h (and possibly explain how it coexists with _SPECIAL).


> Am I right in supposing that _PAGE_SPECIAL can only be set on user pages?

Yes.


> (Also, "SPECIAL" is awfully generic.  Was there really no more
> descriptive name for this?)

I thought it was about on par with its counterpart, which is "normal".
Either way, I don't think a casual reader would get an adequate idea
of how it works in one word. normal ~= refcounted, special ~= !refcounted
I guess, but it is slightly more than that and besides, normal was there
first, and I think Linus coined it... if you can convince him to change
it then you have my blessing to change special into whatever you want.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
