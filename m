Date: Sun, 26 Jun 2005 21:24:06 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable
 for other purposes
In-Reply-To: <Pine.LNX.4.62.0506261928010.1679@graphe.net>
Message-ID: <Pine.LNX.4.58.0506262121070.19755@ppc970.osdl.org>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net>
 <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242311220.7971@graphe.net>
 <20050626023053.GA2871@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506251954470.26198@graphe.net>
 <20050626030925.GA4156@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506261928010.1679@graphe.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com
List-ID: <linux-mm.kvack.org>


On Sun, 26 Jun 2005, Christoph Lameter wrote:
> 
> 3. I wish there would be a better way to handle the PF_FREEZE. Its like a 
> signal delivery after all. Is there any way to define an in kernel signal? 
> Or a way to make a process execute a certain bit of code?

It's called "work", and we have the "TIF_xxx" flags for it. That's how 
"need-resched" and "sigpending" are done. There could be a 
"TIF_FREEZEPENDING" thing there too..

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
