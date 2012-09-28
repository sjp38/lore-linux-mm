Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 736806B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:44:29 -0400 (EDT)
Received: by eaak11 with SMTP id k11so1344897eaa.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 12:44:27 -0700 (PDT)
Message-ID: <5065FE29.5080302@gmail.com>
Date: Fri, 28 Sep 2012 21:44:41 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
References: <1340959739.2936.28.camel@lappy> <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com> <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com> <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com> <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com> <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com> <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com> <1347202600.5876.7.camel@sbsiddha-ivb> <505068F4.4080309@gmail.com> <50506A6C.30109@gmail.com> <50656733.3040609@gmail.com> <CA+55aFyWdxD4Qb9PuPKKx_Ww_khYkWg1s-3QWVUwsTSXSUMG5w@mail.gmail.com> <1348855547.1556.3.camel@kyv> <CA+55aFwDWcQv9DBCQhMrcK-zx75qBN11iQhq5dxt+orosmeXbg@mail.gmail.com>
In-Reply-To: <CA+55aFwDWcQv9DBCQhMrcK-zx75qBN11iQhq5dxt+orosmeXbg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, suresh.b.siddha@intel.com, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On 09/28/2012 09:13 PM, Linus Torvalds wrote:
> On Fri, Sep 28, 2012 at 11:05 AM, Artem Bityutskiy <dedekind1@gmail.com> wrote:
>>
>> I am not the maintainer, but please, go ahead an push your fix. I do not
>> have time to test it myself and it does not look like anyone else in the
>> small mtd community does.
> 
> Grr. I told people that patch wasn't tested. I hadn't even *compiled*
> it. It has a typo ("inlint" instead of "inline" - so close).
> 
> Sasha said he had tested it, but nobody even mentioned this thing. Now
> I'm nervous. I had committed it in my tree and was just about to push
> it out when I decided that I should at least compile it despite the
> "tested-by".
> 
> Hmm? Now I really *really* want to know that it's been tested on
> actual hardware too. Sasha, what patch did you actually test? Did you
> just fix the "inlint" thing, or was there something else entirely?

I've just fixed the inlint thing since it was pretty trivial, I didn't bother commenting on it since I figured it would turn into
an actual patch from someone who could test it on actual hardware first.

Note that I've tested it on a KVM guest, and not on real hardware - so I'm not sure how much of a test that is.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
