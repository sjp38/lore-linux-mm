Date: Wed, 13 Feb 2008 11:43:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] acpi: change cpufreq tables to per_cpu variables
Message-Id: <20080213114317.0698a2b2.akpm@linux-foundation.org>
In-Reply-To: <47B33278.3060408@sgi.com>
References: <20080208233738.108449000@polaris-admin.engr.sgi.com>
	<20080208233738.427702000@polaris-admin.engr.sgi.com>
	<20080212153356.d2be3248.akpm@linux-foundation.org>
	<47B33278.3060408@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, ak@suse.de, clameter@sgi.com, steiner@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, len.brown@intel.com, linux-acpi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008 10:10:00 -0800
Mike Travis <travis@sgi.com> wrote:

> Andrew Morton wrote:
> > On Fri, 08 Feb 2008 15:37:40 -0800
> > Mike Travis <travis@sgi.com> wrote:
> > 
> >> Change cpufreq tables from arrays to per_cpu variables in
> >> drivers/acpi/processor_thermal.c
> >>
> >> Based on linux-2.6.git + x86.git
> > 
> > I fixed a bunch of rejects in "[PATCH 1/4] cpufreq: change cpu freq tables
> > to per_cpu variables" and it compiles OK.  But this one was beyond my
> > should-i-repair-it threshold, sorry.
> 
> Should I rebase all the pending patches on 2.6.25-rc1 or 2.6.24-mm1
> (or some other combination)?
> 

That depends on whether you have other things queued in one of the git
trees.  If not, against current mainline (which is later than 2.6.25-rc1!)
would suit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
