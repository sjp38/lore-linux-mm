Subject: Re: 2.6.4-mm2
From: Mary Edie Meredith <maryedie@osdl.org>
Reply-To: maryedie@osdl.org
In-Reply-To: <20040319183906.I8594@osdlab.pdx.osdl.net>
References: <20040314172809.31bd72f7.akpm@osdl.org>
	 <200403181737.i2IHbCE09261@mail.osdl.org>
	 <20040318100615.7f2943ea.akpm@osdl.org> <20040318192707.GV22234@suse.de>
	 <20040318191530.34e04cb2.akpm@osdl.org>
	 <20040318194150.4de65049.akpm@osdl.org>
	 <20040319183906.I8594@osdlab.pdx.osdl.net>
Content-Type: text/plain
Message-Id: <1079975940.23641.580.camel@localhost>
Mime-Version: 1.0
Date: Mon, 22 Mar 2004 09:19:02 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[was "Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels" on
linux-mm]

Andrew,

This same patch (02) applied in STP (plm 2780) when run against
dbt3-pgsql DSS workload displays the performance problem with the
throughput numbers that I reported on linux-mm on our 8way systems,
where the previous patch (plm 2777 -01) does not.  

Here is the data (patches applied to 2.6.5-rc1)

PLM.....CPUs.Runid..Thruput Metric (bigger is better)
2777(01)  8  290298  138.22  (base  )
2779(02)  8  290304  88.57   (-35.9%)

The 8way is a 700MHz (1024k processor cache) with 8GB of memory.

Original message on linux-mm:
http://marc.theaimsgroup.com/?l=linux-mm&m=107913089923436&w=2

Results from runid 290298 (the good result);
http://khack.osdl.org/stp/290298/  (top level)

Results from runid 290304 (the bad result):
http://khack.osdl.org/stp/290305/  (top level)
For sar results see "Raw data" section everything labeled as
"thruput.sar."
http://khack.osdl.org/stp/290305/profile/after_throughput_test_1-tick.top20  (profile of throughput phase of the test)
http://khack.osdl.org/stp/290305/results/plot/thuput.vmstat.txt
(vmstat of thoughput phase of the test)

On Fri, 2004-03-19 at 18:39, Mark Wong wrote:
> On Thu, Mar 18, 2004 at 07:41:50PM -0800, Andrew Morton wrote:
> > Andrew Morton <akpm@osdl.org> wrote:
> > >
> > > Mark, if it's OK I'll run up some kernels for you to test.
> > 
> > At
> > 
> > 	http://www.zip.com.au/~akpm/linux/patches/markw/
> 
> Ok, looks like I take the first hit with the 02 patch.  Here's re-summary:
> 
> kernel          16 kb   32 kb   64 kb   128 kb  256 kb  512 kb
> 2.6.3                           2308    2335    2348    2334
> 2.6.4-mm2       2028    2048    2074    2096    2082    2078
> 2.6.5-rc1-01                                            2394
> 2.6.5-rc1-02                                            2117
> 2.6.5-rc1-mm2                                           2036
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Mary Edie Meredith 
maryedie@osdl.org
503-626-2455 x42
Open Source Development Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
