Received: by rv-out-0910.google.com with SMTP id f1so860876rvb
        for <linux-mm@kvack.org>; Mon, 06 Aug 2007 02:55:33 -0700 (PDT)
Message-ID: <4d8e3fd30708060255w79a3bbj40f33f7eb80a743f@mail.gmail.com>
Date: Mon, 6 Aug 2007 11:55:32 +0200
From: "Paolo Ciarrocchi" <paolo.ciarrocchi@gmail.com>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
In-Reply-To: <997038.92524.qm@web53809.mail.re2.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0708051916430.6905@asgard.lang.hm>
	 <997038.92524.qm@web53809.mail.re2.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: david@lang.hm, Rene Herman <rene.herman@gmail.com>, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 8/6/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
[...]
> > this completely ignores the use case where the
> > swapping was exactly the
> > right thing to do, but memory has been freed up from
> > a program exiting so
> > that you couldnow fill that empty ram with data that
> > was swapped out.
>
> Yeah. However, merging patches (especially when
> changing heuristics, especially in page reclaim) is
> not about just thinking up a use-case that it works
> well for and telling people that they're putting their
> heads in the sand if they say anything against it.
> Read this thread and you'll find other examples of
> patches that have been around for as long or longer
> and also have some good use-cases and also have not
> been merged.

What do you think Andrew?
Swap prefetch is not the panacea, it's not going to solve all the
problems but it seems to improve the "desktop experience" and it has
been discussed and reviewed a lot (it's has even been discussed more
than it should have be).

Are you going to push upstream the patch?

Ciao,
-- 
Paolo
http://paolo.ciarrocchi.googlepages.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
