Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A56CE6B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 13:27:25 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id z53so3404369wey.15
        for <linux-mm@kvack.org>; Fri, 15 Mar 2013 10:27:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130315165509.GA1108@cmpxchg.org>
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
	<5142E411.2040005@gmail.com>
	<CAA25o9RPhu++JsX_8AjhqJuodRkybiYVSEifjCXX=oPnOO5fEA@mail.gmail.com>
	<20130315165509.GA1108@cmpxchg.org>
Date: Fri, 15 Mar 2013 10:27:23 -0700
Message-ID: <CAA25o9SsVppWQ+Hi4LQ5OkiENHF5BQeNVD_G+a7CUbnPgOm=YQ@mail.gmail.com>
Subject: Re: security: restricting access to swap
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Will Drewry <drewry@google.com>
Cc: Ric Mason <ric.masonn@gmail.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Fri, Mar 15, 2013 at 9:55 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Fri, Mar 15, 2013 at 08:48:49AM -0700, Luigi Semenzato wrote:
>> On Fri, Mar 15, 2013 at 2:04 AM, Ric Mason <ric.masonn@gmail.com> wrote:
>> > On 03/12/2013 07:57 AM, Luigi Semenzato wrote:
>> >>
>> >> Greetings linux-mmers,
>> >>
>> >> before we can fully deploy zram, we must ensure it conforms to the
>> >> Chrome OS security requirements.  In particular, we do not want to
>> >> allow user space to read/write the swap device---not even root-owned
>> >> processes.
>> >
>> >
>> > Interesting.
>>
>> Thank you.
>>
>> >>
>> >> A similar restriction is available for /dev/mem under
>> >> CONFIG_STRICT_DEVMEM.
>> >
>> >
>> > Sorry, what's /dev/mem used for?  and why relevant your topic?
>>
>> I don't know what it's used for Chrome OS, but I don't think it
>> matters.  The point is that /dev/mem is compiled in the kernel, and
>> without CONFIG_STRICT_DEVMEM it offers a way for a root-owned process
>> to read/write all of physical memory.  The situation is not as dire
>> with a swap device, but currently a root-owned process can open a
>> block device used for swap and peek and poke its data, which means
>> that a root-owned process has now potential access to the data segment
>> of any other process, among other things.
>
> How do you handle /proc/<pid>/mem?

Right.  We do not.  But... we might!  We could turn it off and see if
it breaks anything important.

In any case, we don't like expanding the attack surface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
