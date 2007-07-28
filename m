Message-ID: <46AB0380.6000302@gmail.com>
Date: Sat, 28 Jul 2007 10:51:12 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge	plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net> <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com> <20070727231545.GA14457@atjola.homenet> <46AAF1CF.6060908@gmail.com>
In-Reply-To: <46AAF1CF.6060908@gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-15?Q?Bj=F6rn_Steinbrink?= <B.Steinbrink@gmx.de>
Cc: Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/28/2007 09:35 AM, Rene Herman wrote:

> By the way -- I'm unable to make my slocate grow substantial here but 
> I'll try what GNU locate does. If it's really as bad as I hear then 
> regardless of anything else it should really be either fixed or dumped...

Yes. GNU locate is broken and nobody should be using it. The updatedb from 
(my distribution standard) "slocate" uses around 2M allocated total during 
an entire run while GNU locate allocates some 30M to the sort process alone.

GNU locate is also close to 4 times as slow (although that ofcourse only 
matters on cached runs anyways).

So, GNU locate is just a pig pushing things out, with or without any added 
VFS cache pressure from the things it does by design. As such, we can trust 
people complaining about it but should first tell them to switch to halfway 
sane locate implementation. If you run memory hogs on small memory boxes, 
you're going to suffer.

Leaves the fact that swap-prefetch sometimes helps alleviate these and other 
kinds of memory-hog situations and as such, might not (again) be a bad idea 
in itself.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
