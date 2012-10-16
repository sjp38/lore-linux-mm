Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 61A956B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 19:39:50 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so8418997oag.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 16:39:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
 <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
 <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com> <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 16 Oct 2012 19:39:29 -0400
Message-ID: <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
Subject: Re: mpol_to_str revisited.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Oct 16, 2012 at 2:10 AM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 16 Oct 2012, KOSAKI Motohiro wrote:
>
>> >> I don't think 80de7c3138ee9fd86a98696fd2cf7ad89b995d0a is right fix.
>> >
>> > It's certainly not a complete fix, but I think it's a much better result
>> > of the race, i.e. we don't panic anymore, we simply fail the read()
>> > instead.
>>
>> Even though 80de7c3138ee9fd86a98696fd2cf7ad89b995d0a itself is simple. It bring
>> to caller complex. That's not good and have no worth.
>>
>
> Before: the kernel panics, all workloads cease.
> After: the file shows garbage, all workloads continue.
>
> This is better, in my opinion, but at best it's only a judgment call and
> has no effect on anything.

Kernel panics help to find our serious mistake.


> I agree it would be better to respect the return value of mpol_to_str()
> since there are other possible error conditions other than a freed
> mempolicy, but let's not consider reverting 80de7c3138.  It is obviously
> not a full solution to the problem, though, and we need to serialize with
> task_lock().

Sorry no. I will have to revert it. mempolicy have already a lot of
meaningless complex and bring us a lot of problems. I haven't
seen any reason adding more.


> Dave, are you interested in coming up with a patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
