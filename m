Date: Sun, 26 Jun 2005 00:37:15 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable for other purposes
Message-ID: <20050625223715.GA11438@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242127040.3433@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0506242127040.3433@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Hi!
> > > I only know that this boots correctly since I have no system that can do 
> > > suspend. But Ray needs an effective means of process suspension for 
> > > his process migration patches.
> > 
> > Any i386 or x86-64 machine can do suspend... It should be easy to get
> > some notebook... [What kind of hardware are you working on normally?]
> 
> Umm... Sorry to be so negative but that has never worked for me on lots of 
> laptops. Usually something with ACPI or some driver I guess... After 
> awhile I gave up trying.

You should be able to do acpi=off if it gives you a problem. Going
with minimal drivers help, too...

> > Previous code had important property: try_to_freeze was optimized away
> > in !CONFIG_PM case. Please keep that.
> 
> Obviously that will not work if we use try_to_freeze for 
> non-power-management purposes. The code from kernel/power/process.c may 
> have to be merged into some other kernel file. kernel/sched.c?

You want to use it for process migration, right? Not everyone wants
either software or process migration... We may want to keep overhead
low for embedded systems...

								Pavel 

-- 
Boycott Kodak -- for their patent abuse against Java.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
