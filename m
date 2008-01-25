Message-ID: <47993428.7000001@sgi.com>
Date: Thu, 24 Jan 2008 16:58:16 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] percpu: Optimize percpu accesses
References: <20080123044924.508382000@sgi.com> <20080124224613.GA24855@elte.hu> <47992AA8.6040804@sgi.com> <20080125002543.GA931@elte.hu>
In-Reply-To: <20080125002543.GA931@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Mike Travis <travis@sgi.com> wrote:
> 
>>> tried it on x86.git and 1/3 did not build and 2/3 causes a boot hang 
>>> with the attached .config.
>> The build error was fixed with the note I sent to you yesterday with a 
>> "fixup" patch for changes in -mm but not in x86.git (attached).
> 
> no, that build error was in patch #2, and your later patch made it 
> possible for me to bisect down to that point. #1 failed differently. 
> (and not in module.c - dont remember the details - let me know if you 
> cannot reproduce - the hang in #2 was the more significant bug.) The 
> hang gave no messages on the earlyprintk serial console.
> 
> 	Ingo

I may need them then.  I updated to your latest available git tree
and applied the patchset I sent and I got this build error:

kernel/module.c:345: error: expected identifier or '(' before 'char'
kernel/module.c:345: error: expected ')' before numeric constant

With the fixup patch, all my test configs (and your config) build cleanly.

The hang though, I'm getting as well and am debugging it now (alibi
slowly since it's happening so early.  Too bad grub doesn't have kdb
in it... ;-)

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
