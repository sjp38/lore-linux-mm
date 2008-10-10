Date: Fri, 10 Oct 2008 17:39:51 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Message-ID: <20081010153951.GD28977@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu> <20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz> <20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz> <20081009134415.GA12135@elte.hu> <1223571036.11830.32.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223571036.11830.32.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

* Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Thu, 2008-10-09 at 15:44 +0200, Ingo Molnar wrote:
> > there might be races as well, especially with proxy state - and 
> > current->flags updates are not serialized.
> > 
> > So maybe it should be a completely separate flag after all? Stick it 
> > into the end of task_struct perhaps.
> 
> What do you mean by proxy state?  nsproxy?

it's a concept: one task installing some state into another task (which 
state must be restored after a checkpoint event), while that other task 
is running. Such as a pi-futex state for example.

So a task can acquire state not just by its own doing, but via some 
other task too.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
