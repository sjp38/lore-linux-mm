Message-ID: <46A70D37.3060005@gmail.com>
Date: Wed, 25 Jul 2007 10:43:35 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm> <46A6DFFD.9030202@gmail.com> <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com> <20070725082822.GA13098@elte.hu>
In-Reply-To: <20070725082822.GA13098@elte.hu>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Valdis.Kletnieks@vt.edu, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/25/2007 10:28 AM, Ingo Molnar wrote:

>> Regardless, I'll stand by "[by disabling updatedb] the problem will 
>> for a large part be solved" as I expect approximately 94.372 percent 
>> of Linux desktop users couldn't care less about locate.
> 
> i think that approach is illogical: because Linux mis-handled a mixed 
> workload the answer is to ... remove a portion of that workload?

No. It got snipped but I introduced the comment by saying it was a "that's 
not the point" kind of thing. Sometimes things that aren't the point are 
still true though and in the case of Linux desktop users complaining about 
updatedb runs, a comment that says that for many an obvious solution would 
be to stop running the damned thing is not in any sense illogical.

Also note I'm not against swap prefetch or anything. I don't use it and do 
not believe I have a pressing need for it, but do suspect it has potential 
to make quite a bit of difference on some things -- if only to drastically 
reduce seeks if it means it's swapping in larger chunks than a randomly 
faulting program would.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
