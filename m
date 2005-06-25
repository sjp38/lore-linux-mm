Date: Fri, 24 Jun 2005 21:31:12 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable
 for other purposes
In-Reply-To: <20050625025122.GC22393@atrey.karlin.mff.cuni.cz>
Message-ID: <Pine.LNX.4.62.0506242127040.3433@graphe.net>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net>
 <20050625025122.GC22393@atrey.karlin.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Jun 2005, Pavel Machek wrote:

> > I only know that this boots correctly since I have no system that can do 
> > suspend. But Ray needs an effective means of process suspension for 
> > his process migration patches.
> 
> Any i386 or x86-64 machine can do suspend... It should be easy to get
> some notebook... [What kind of hardware are you working on normally?]

Umm... Sorry to be so negative but that has never worked for me on lots of 
laptops. Usually something with ACPI or some driver I guess... After 
awhile I gave up trying.

> > But is this the correct way to fix this?
> It includes whitespace changes and most of patch is nice cleanup that
> should probably go in separately. (Hint hint :-). 

Ok.

> Previous code had important property: try_to_freeze was optimized away
> in !CONFIG_PM case. Please keep that.

Obviously that will not work if we use try_to_freeze for 
non-power-management purposes. The code from kernel/power/process.c may 
have to be merged into some other kernel file. kernel/sched.c?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
