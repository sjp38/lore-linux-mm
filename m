Date: Mon, 27 Jun 2005 20:05:08 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable for other purposes
Message-ID: <20050627180507.GA28815@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <1104805430.20050625113534@sw.ru> <42BFA591.1070503@engr.sgi.com> <20050627131709.GA30467@atrey.karlin.mff.cuni.cz> <42C01455.7020803@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42C01455.7020803@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Kirill Korotaev <dev@sw.ru>, Christoph Lameter <christoph@lameter.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi!

> >Should be very easy to solve with one semaphore. Simply make swsusp
> >wait until all migrations are done.  
> 
> This may not be needed.  If I understand things correctly, the system
> won't suspsend until all tasks have returned from system calls and end
> up in the refrigerator.  So if a memory migration is  running when
> someone tries to suspend the system, the suspend won't
> occur until the memory migration system call returns.
> 
> Is that correct?

No, because now migration tries to using same freezer
mechanism. Oops. Semaphore solves it nicely....

								Pavel
-- 
Boycott Kodak -- for their patent abuse against Java.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
