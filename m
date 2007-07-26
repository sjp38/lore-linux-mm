Message-ID: <46A81F67.1040502@garzik.org>
Date: Thu, 26 Jul 2007 00:13:27 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm> <a781481a0707251033t5b95cde7k620810bcc0b98c1@mail.gmail.com> <20070725203523.GA10750@elte.hu> <200707260432.52739.bzolnier@gmail.com>
In-Reply-To: <200707260432.52739.bzolnier@gmail.com>
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Satyam Sharma <satyam.sharma@gmail.com>, Rene Herman <rene.herman@gmail.com>, Jos Poortvliet <jos@mijnkamer.nl>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Bartlomiej Zolnierkiewicz wrote:
> On Wednesday 25 July 2007, Ingo Molnar wrote:
>> you dont _have to_ cooperative with the maintainer, but it's certainly 
>> useful to work with good maintainers, if your goal is to improve Linux. 
>> Or if for some reason communication is not working out fine then grow 
>> into the job and replace the maintainer by doing a better job.
> 
> The idea of growing into the job and replacing the maintainer by proving
> the you are doing better job was viable few years ago but may not be
> feasible today.

IMO...  Tejun is an excellent counter-example.  He showed up as an 
independent developer, put a bunch of his own spare time and energy into 
the codebase, and is probably libata's main engineer (in terms of code 
output) today.  If I get hit by a bus tomorrow, I think the Linux 
community would be quite happy with him as the libata maintainer.


> The another problem is that sometimes it seems that independent developers
> has to go through more hops than entreprise ones and it is really frustrating
> experience for them.  There is no conspiracy here - it is only the natural
> mechanism of trusting more in the code of people who you are working with more.

I think Tejun is a counter-example here too :)  Everyone's experience is 
different, but from my perspective, Tejun "appeared out of nowhere" 
producing good code, and so, it got merged rapidly.

Personally, for merging code, I tend to trust people who are most in 
tune with "the Linux Way(tm)."  It is hard to quantify, but quite often, 
independent developers "get it" when enterprise developers do not.


> Now could I ask people to stop all this -ck threads and give the developers
> involved in the recent events some time to calmly rethink the whole case.

Indeed...

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
