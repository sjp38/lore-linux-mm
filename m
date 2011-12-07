Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5371C6B004D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 06:02:30 -0500 (EST)
Received: by yenm3 with SMTP id m3so451846yen.26
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 03:02:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201112071011.03525.arnd@arndb.de>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <201112051718.48324.arnd@arndb.de> <CAB2ybb8-0_HupO95UUvLN9ovVxnU+uvn4UXbwqZLSFuC9MZs0w@mail.gmail.com>
 <201112071011.03525.arnd@arndb.de>
From: "Semwal, Sumit" <sumit.semwal@ti.com>
Date: Wed, 7 Dec 2011 16:32:08 +0530
Message-ID: <CAB2ybb9yiHLzB9iW_EhBvEkvo3n82phkfS+d1J7yXi+ZZt=kDw@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>

On Wed, Dec 7, 2011 at 3:41 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wednesday 07 December 2011, Semwal, Sumit wrote:
>> >
>> > Do you have a use case for making the interface compile-time disabled?
>> > I had assumed that any code using it would make no sense if it's not
>> > available so you don't actually need this.
>>
>> Ok. Though if we keep the interface compile-time disabled, the users
>> can actually check and fail or fall-back gracefully when the API is
>> not available; If I remove it, anyways the users would need to do the
>> same compile time check whether API is available or not, right?
>
> If you have to do a compile-time check for the config symbol, it's better
> to do it the way you did here than in the caller.
>
> My guess was that no caller would actually require this, because when you
> write a part of a subsystem to interact with the dma-buf infrastructure,
> you would always disable compilation of an extire file that deals with
> everything related to struct dma_buf, not just stub out the calls.

Right; that would be ideal, but we may not be able to ask each user to
do so - especially when the sharing part might be interspersed in
existing buffer handling code. So for now, I would like to keep it as
it-is.
>
> =A0 =A0 =A0 =A0Arnd
>
BR,
~Sumit.
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
