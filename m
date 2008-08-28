Message-ID: <48B5F5A6.4060309@goop.org>
Date: Wed, 27 Aug 2008 17:47:34 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Definition of x86 _PAGE_SPECIAL and sharing _PAGE_UNUSED1
References: <48B5A4B0.9050308@goop.org> <200808281032.30594.nickpiggin@yahoo.com.au>
In-Reply-To: <200808281032.30594.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, Hugh Dickens <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Ah... pity it was hidden away there and not put into the include file.
>   

Yes.  I just prepped a patch to bring it out into the light.

> I don't feel strongly about it. But you should put your definition in
> pgtable.h (and possibly explain how it coexists with _SPECIAL).
>   

Yes, that was my plan, but without knowing how _SPECIAL is used, it's a
bit tricky.  Is there a comment somewhere which describes who sets it
and when?  From a quick look, it seems it's set on newly added user
pages which aren't COWed.  Can they be shared file-backed pages? 
Anonymous pages?  Device pages?

>> Am I right in supposing that _PAGE_SPECIAL can only be set on user pages?
>>     
>
> Yes.
>   

OK, that won't clash with CPA tests at all, since they're kernel only.

>> (Also, "SPECIAL" is awfully generic.  Was there really no more
>> descriptive name for this?)
>>     
>
> I thought it was about on par with its counterpart, which is "normal".
> Either way, I don't think a casual reader would get an adequate idea
> of how it works in one word. normal ~= refcounted, special ~= !refcounted
> I guess, but it is slightly more than that and besides, normal was there
> first, and I think Linus coined it... if you can convince him to change
> it then you have my blessing to change special into whatever you want.
>   

It's only used in a couple of places, so giving it a longer name
wouldn't cost much.  _PAGE_USER_UNCOUNTED?  But ugh, a lot of cross-arch
churnpatch to do it.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
