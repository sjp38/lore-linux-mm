Message-ID: <46A7074B.50608@gmail.com>
Date: Wed, 25 Jul 2007 10:18:19 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <200707102015.44004.kernel@kolivas.org> <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>            <46A6DFFD.9030202@gmail.com> <30701.1185347660@turing-police.cc.vt.edu>
In-Reply-To: <30701.1185347660@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/25/2007 09:14 AM, Valdis.Kletnieks@vt.edu wrote:

> On Wed, 25 Jul 2007 07:30:37 +0200, Rene Herman said:
> 
>> Yes, but what's locate's usage scenario? I've never, ever wanted to use
>> it. When do you know the name of something but not where it's located,
>> other than situations which "which" wouldn't cover and after just
>> having installed/unpacked something meaning locate doesn't know about
>> it yet either?
> 
> My favorite use - with 5 Fedora kernels and as many -mm kernels on my
> laptop, doing a 'locate moby' finds all the moby.c and moby.o and moby.ko
> for the various releases.

Supposing you know the path in one tree, you know the path in all of them, 
right? :-?

> You want hard numbers? Here you go - 'locate' versus 'find'

These are ofcourse not necesary. If you discount the time updatedb itself 
takes it's utterly obvious that _if_ you use it, it's going to be wildly 
faster than find.

Regardless, I'll stand by "[by disabling updatedb] the problem will for a 
large part be solved" as I expect approximately 94.372 percent of Linux 
desktop users couldn't care less about locate.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
