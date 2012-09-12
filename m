Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 9BCFE6B00BA
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 06:50:04 -0400 (EDT)
Received: by eaaf11 with SMTP id f11so873707eaa.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 03:50:02 -0700 (PDT)
Message-ID: <505068F4.4080309@gmail.com>
Date: Wed, 12 Sep 2012 12:50:28 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
References: <1340959739.2936.28.camel@lappy>  <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>  <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>  <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>  <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>  <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com>  <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com> <1347202600.5876.7.camel@sbsiddha-ivb>
In-Reply-To: <1347202600.5876.7.camel@sbsiddha-ivb>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: suresh.b.siddha@intel.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On 09/09/2012 04:56 PM, Suresh Siddha wrote:
> On Sat, 2012-09-08 at 12:57 -0700, Linus Torvalds wrote:
>> > Whatever. Something like this (TOTALLY UNTESTED) attached patch should
>> > get the mtdchar overflows to go away, 
> It looks good to me. Acked-by: Suresh Siddha <suresh.b.siddha@intel.com>
> 
> Sasha, can you please give this a try?

Sorry for the delay. It looks good here.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
