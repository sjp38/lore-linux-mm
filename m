Date: Mon, 22 Mar 2004 16:27:29 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.4-mm2
Message-Id: <20040322162729.2f2ddbe4.akpm@osdl.org>
In-Reply-To: <1079975940.23641.580.camel@localhost>
References: <20040314172809.31bd72f7.akpm@osdl.org>
	<200403181737.i2IHbCE09261@mail.osdl.org>
	<20040318100615.7f2943ea.akpm@osdl.org>
	<20040318192707.GV22234@suse.de>
	<20040318191530.34e04cb2.akpm@osdl.org>
	<20040318194150.4de65049.akpm@osdl.org>
	<20040319183906.I8594@osdlab.pdx.osdl.net>
	<1079975940.23641.580.camel@localhost>
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
> [was "Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels" on
> linux-mm]
> 
> Andrew,
> 
> This same patch (02) applied in STP (plm 2780) when run against
> dbt3-pgsql DSS workload displays the performance problem with the
> throughput numbers that I reported on linux-mm on our 8way systems,
> where the previous patch (plm 2777 -01) does not.  
> 
> Here is the data (patches applied to 2.6.5-rc1)
> 
> PLM.....CPUs.Runid..Thruput Metric (bigger is better)
> 2777(01)  8  290298  138.22  (base  )
> 2779(02)  8  290304  88.57   (-35.9%)

36% regression due to the CPU scheduler changes?  ow.

And that machine is a PIII, so presumably the setting of CONFIG_SCHED_SMT
makes no difference.

>From a quick look at the material you have there it appears that this
workload also is very I/O bound.  It's a little surprising that the CPU
scheduler could make so much difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
