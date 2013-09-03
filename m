Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 1FE506B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:49:54 -0400 (EDT)
Received: by mail-bk0-f54.google.com with SMTP id mz12so1970175bkb.13
        for <linux-mm@kvack.org>; Tue, 03 Sep 2013 00:49:52 -0700 (PDT)
Message-ID: <5225949C.9030201@colorfullife.com>
Date: Tue, 03 Sep 2013 09:49:48 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: ipc-msg broken again on 3.11-rc7?
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com> <521DE5D7.4040305@synopsys.com> <CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com> <CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com> <52205597.3090609@synopsys.com> <CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com> <CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com> <CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com> <CA+55aFy8tbBpac57fU4CN3jMDz46kCKT7+7GCpb18CscXuOnGA@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA230751413F4@IN01WEMBXA.internal.synopsys.com> <5224BCF6.2080401@colorfullife.com> <CA+icZUVc6fhW+TTB56x68LooS8DqhA8n3CQzgKkXQmbyH+ryUQ@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA2307514160B@IN01WEMBXA.internal.synopsys.com>
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA2307514160B@IN01WEMBXA.internal.synopsys.com>
Content-Type: multipart/alternative;
 boundary="------------020005030001010506050103"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

This is a multi-part message in MIME format.
--------------020005030001010506050103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Vineet,

On 09/03/2013 09:34 AM, Vineet Gupta wrote:
> However assuming we are going ahead with debugging this - can you 
> please confirm whether you see the issue on x86 as well as I have not 
> tested that ? I vaguely remember one of your earlier posts suggested 
> you did Thx, -Vineet 
I'm unable to reproduce the issue so far. I ran
- something like 4000 stock msgctl08 with 4 cores on x86.
- a few runs with modified msgctl08 with either slowed down reader or 
slowed down writer threads. (i.e.: force queue full or queue empty waits).
- a few runs (modified&unmodified) with all but one core taken offline.

I have not yet tested with PREEMPT enabled.

A few more ideas:
- what is the output of ipcs -q? Are the queues empty or full?
- what is the output of then WCHAN field with ps when it hangs?
Something like
/ #ps/ -o pid,f,stat,pcpu,pmem,psr,/wchan/=/WIDE/-/WCHAN/ -o comm,args

--
     Manfred

--------------020005030001010506050103
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">Hi Vineet,<br>
      <br>
      On 09/03/2013 09:34 AM, Vineet Gupta wrote:<br>
    </div>
    <blockquote
cite="mid:C2D7FE5348E1B147BCA15975FBA2307514160B@IN01WEMBXA.internal.synopsys.com"
      type="cite">
      However assuming we are going ahead with debugging this - can you
      please confirm
      whether you see the issue on x86 as well as I have not tested that
      ? I vaguely
      remember one of your earlier posts suggested you did
      Thx,
      -Vineet
    </blockquote>
    I'm unable to reproduce the issue so far. I ran<br>
    - something like 4000 stock msgctl08 with 4 cores on x86.<br>
    - a few runs with modified msgctl08 with either slowed down reader
    or slowed down writer threads. (i.e.: force queue full or queue
    empty waits).<br>
    - a few runs (modified&amp;unmodified) with all but one core taken
    offline.<br>
    <br>
    I have not yet tested with PREEMPT enabled.<br>
    <br>
    A few more ideas:<br>
    - what is the output of ipcs -q? Are the queues empty or full?<br>
    - what is the output of then WCHAN field with ps when it hangs?<br>
    Something like<br>
    <span class="st"><em>&nbsp;#ps</em> -o pid,f,stat,pcpu,<wbr>pmem,psr,<em>wchan</em>=<em>WIDE</em>-<em>WCHAN</em>
      -o comm,args</span><br>
    <br>
    --<br>
    &nbsp;&nbsp;&nbsp; Manfred<br>
  </body>
</html>

--------------020005030001010506050103--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
