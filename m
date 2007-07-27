Date: Sat, 28 Jul 2007 01:29:19 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Message-ID: <20070727232919.GA8960@one.firstfloor.org>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net> <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com> <20070727231545.GA14457@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070727231545.GA14457@atjola.homenet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>, Rene Herman <rene.herman@gmail.com>, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Any faults in that reasoning?

GNU sort uses a merge sort with temporary files on disk. Not sure
how much it keeps in memory during that, but it's probably less
than 150MB. At some point the dirty limit should kick in and write back the 
data of the temporary files; so it's not quite the same as anonymous memory. 
But it's not that different given.

It would be better to measure than to guess. At least Andrew's measurements
on 128MB actually didn't show updatedb being really that big a problem.

Perhaps some people have much more files or simply a less efficient
updatedb implementation?

I guess the people who complain here that loudly really need to supply
some real numbers. 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
