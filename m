Date: Mon, 27 Jun 2005 06:21:38 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable for other purposes
Message-ID: <20050627042137.GA27710@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242311220.7971@graphe.net> <20050626023053.GA2871@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506251954470.26198@graphe.net> <20050626030925.GA4156@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506261928010.1679@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0506261928010.1679@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Hi!

> > > Why do you want to specify a parameter that is never used? It was quite confusing to me 
> > > and I would think that such a parameter will also be confusing to others.
> > 
> > Well, yes, it is slightly confusing, but such patch can go in through
> > different maintainers, and different pieces can come in at different
> > times.
> 
> The cleanup patch is already in Linus' tree so the discussion is moot. So 
> I think the basic API is now stable.

Okay, good. I was worried I'll have to push it myself.

> The other outstanding issues may best be addressed in the 
> following way.
> 
> 1. Have a semaphore to insure that allows control over the freezing 
> process. Each action involving freezing of processes needs to first 
> take the semaphore. This will insure that only the suspend code or the 
> process migration code (or something else in the future) are freezing processes.
> 
> 2. A completion handler seems to be the right instrument in the 
> refrigerator and allows the removal of a lot of code.
> 
> 3. I wish there would be a better way to handle the PF_FREEZE. Its like a 
> signal delivery after all. Is there any way to define an in kernel signal? 
> Or a way to make a process execute a certain bit of code?

Well... but kernel threads are simply not designed to handle signals,
that's why we had to add all those try_to_freeze()s.

> The following patch will still need to be verified to be correct, 
> cleaned up to move code around and do the right thing with 
> CONFIG_FREEZING CONFIG_PM and CONFIG_MIGRATE???

I'm not able to test the patch now (have to get some sleep, etc), but
it looks good.

								Pavel
-- 
Boycott Kodak -- for their patent abuse against Java.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
