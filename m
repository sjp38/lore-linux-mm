Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing
	usable for other purposes
From: Nigel Cunningham <ncunningham@cyclades.com>
Reply-To: ncunningham@cyclades.com
In-Reply-To: <Pine.LNX.4.62.0506242127040.3433@graphe.net>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net>
	 <20050625025122.GC22393@atrey.karlin.mff.cuni.cz>
	 <Pine.LNX.4.62.0506242127040.3433@graphe.net>
Content-Type: text/plain
Message-Id: <1119674790.4170.6.camel@localhost>
Mime-Version: 1.0
Date: Sat, 25 Jun 2005 14:46:30 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, raybry@engr.sgi.com, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Sat, 2005-06-25 at 14:31, Christoph Lameter wrote:
> > Previous code had important property: try_to_freeze was optimized away
> > in !CONFIG_PM case. Please keep that.
> 
> Obviously that will not work if we use try_to_freeze for 
> non-power-management purposes. The code from kernel/power/process.c may 
> have to be merged into some other kernel file. kernel/sched.c?

Do you have a non-power-management purpose in mind?

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
