Date: Mon, 1 Nov 2004 17:55:49 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
Message-ID: <20041102015549.GR2583@holomorphy.com>
References: <4181EF2D.5000407@yahoo.com.au> <20041029074607.GA12934@holomorphy.com> <Pine.LNX.4.58.0411011612060.8399@server.graphe.net> <20041102005439.GQ2583@holomorphy.com> <4186E41E.5080909@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4186E41E.5080909@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <christoph@lameter.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2004 at 12:34:22PM +1100, Nick Piggin wrote:
> Why do you say the audits need to be better? No doubt there will
> still be bugs, but I didn't just say "ahh let's remove the lock
> from around the tlb operations and pray it works".
> I could very well be missing something though - You must be
> seeing some fundamental problems or nasty bugs to say that it's
> been designed it in a vacuum, and that the audits are no good...
> What are they please?

How many times does it take? No, and I'm not looking for you. You have
the burden of proof.

You yourself claimed you hadn't audited the things. The question
this raised was rather obvious:

	If you didn't even look at them, how do you have any idea
	it's going to work for them?

All that needs to be supplied is sufficient evidence, collected
from 20 spots around the VM (arch code), and for that matter, in
summary form ("I audited all architectures"). This should not be in
the form of a lie, not to imply you would do that. The sparc64 analysis
you gave is actually somewhat off but it doesn't really matter so long
as there's actual diligence instead of simultaneous claims of
sufficiency and non-diligence.

I am not even looking at the code. I have my own work to do. I
respectfully ask that when you do your own, you exercise the kind
of diligence I described above as opposed to the kind of affiar you
described in your announcement.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
