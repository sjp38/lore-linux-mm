Date: Tue, 23 Mar 2004 11:32:19 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.4-mm2
Message-Id: <20040323113219.506a7581.akpm@osdl.org>
In-Reply-To: <1080069704.10668.122.camel@localhost>
References: <20040314172809.31bd72f7.akpm@osdl.org>
	<200403181737.i2IHbCE09261@mail.osdl.org>
	<20040318100615.7f2943ea.akpm@osdl.org>
	<20040318192707.GV22234@suse.de>
	<20040318191530.34e04cb2.akpm@osdl.org>
	<20040318194150.4de65049.akpm@osdl.org>
	<20040319183906.I8594@osdlab.pdx.osdl.net>
	<1079975940.23641.580.camel@localhost>
	<20040322162729.2f2ddbe4.akpm@osdl.org>
	<1080069704.10668.122.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: maryedie@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mary Edie Meredith <maryedie@osdl.org> wrote:
>
> > 36% regression due to the CPU scheduler changes?  ow.
>  > 
>  > And that machine is a PIII, so presumably the setting of CONFIG_SCHED_SMT
>  > makes no difference.
>  > 
>  > >From a quick look at the material you have there it appears that this
>  > workload also is very I/O bound.  It's a little surprising that the CPU
>  > scheduler could make so much difference.
>  I'm not sure why you think this is IO bound. For 
>  the throughput phase of the test (from which the 
>  metric above is taken) there is very little physical 
>  IO except at the start when the updates occur.  They
>  finish in a few minutes, after which there is very
>  little.
> 
>  http://khack.osdl.org/stp/290304/results/plot/thuput.vmstat_io.png
>  http://khack.osdl.org/stp/290304/results/plot/thuput.vmstat.txt

There seems to be a large amount of idle time in the profiles and in the
vmstat trace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
