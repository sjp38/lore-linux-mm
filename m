Date: Thu, 23 Jun 2005 16:03:14 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH 2.6.12-rc5 0/10] mm: manual page migration-rc3 -- overview
In-Reply-To: <42BB3EFC.7060800@engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0506231602350.25004@graphe.net>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
 <Pine.LNX.4.62.0506231428330.23673@graphe.net> <42BB3EFC.7060800@engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Jun 2005, Ray Bryant wrote:

> > There is PF_FREEZE flag used by the suspend feature that could be used here
> > to send the process into the "freezer" first. Using regular signals to stop
> > a process may cause races with user space code also doing
> > SIGSTOP SIGCONT on a process while migrating it.
> 
> So are you suggesting that I set PF_FREEZE, wait until PF_FROZEN is set as
> well, then migrate the pages, and then clear PF_FROZEN to resume the task?

Yes.

> I guess that might work, unless we're actually running on a laptop and it
> goes into hibernation at the same time we are trying to do a migration....

You can atomically set the PF_FREEZE flag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
