Received: by el-out-1112.google.com with SMTP id r23so100203elf
        for <linux-mm@kvack.org>; Thu, 26 Jul 2007 17:33:42 -0700 (PDT)
Message-ID: <b21f8390707261733y19e00ca2w9961463bd60c8553@mail.gmail.com>
Date: Fri, 27 Jul 2007 10:33:41 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
In-Reply-To: <20070726102406.GA30165@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de>
	 <46A85D95.509@kingswood-consulting.co.uk>
	 <20070726092025.GA9157@elte.hu>
	 <20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	 <20070726094024.GA15583@elte.hu>
	 <20070726030902.02f5eab0.akpm@linux-foundation.org>
	 <20070726102406.GA30165@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andi Kleen <andi@firstfloor.org>, Frank Kingswood <frank@kingswood-consulting.co.uk>
List-ID: <linux-mm.kvack.org>

On 7/26/07, Ingo Molnar <mingo@elte.hu> wrote:
> wrong, it's active on three of my boxes already :) But then again, i
> never had these hangover problems. (not really expected with gigs of RAM
> anyway)
[...]
> --- /etc/cron.daily/mlocate.cron.orig
[...]

mlocate by design doesn't thrash the cache as much.  People using
slocate (distros other than Redhat ;) are going to be hit worse.  See
http://carolina.mff.cuni.cz/~trmac/blog/mlocate/

updatedb by itself doesn't really bug me, its just that on occasion
its still running at 7am which then doesn't assist my single spindle
come swapin of the other apps!  I'm considering getting one of the old
ide drives out in the garage and shifting swap onto it.  The swap
prefetch patch has mainly assisted me in the "state A -> B -> A"
scenario.  A lot.

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
