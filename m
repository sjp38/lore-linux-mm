Message-ID: <4186F32C.5000400@yahoo.com.au>
Date: Tue, 02 Nov 2004 13:38:36 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <20041029074607.GA12934@holomorphy.com> <Pine.LNX.4.58.0411011612060.8399@server.graphe.net> <20041102005439.GQ2583@holomorphy.com> <4186E41E.5080909@yahoo.com.au> <20041102015549.GR2583@holomorphy.com>
In-Reply-To: <20041102015549.GR2583@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <christoph@lameter.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Tue, Nov 02, 2004 at 12:34:22PM +1100, Nick Piggin wrote:
> 
>>Why do you say the audits need to be better? No doubt there will
>>still be bugs, but I didn't just say "ahh let's remove the lock
>>from around the tlb operations and pray it works".
>>I could very well be missing something though - You must be
>>seeing some fundamental problems or nasty bugs to say that it's
>>been designed it in a vacuum, and that the audits are no good...
>>What are they please?
> 
> 
> How many times does it take? No, and I'm not looking for you. You have
> the burden of proof.
> 

So you don't see any fundamental problems. OK you had me worried
for a minute :)

> You yourself claimed you hadn't audited the things. The question
> this raised was rather obvious:
> 
> 	If you didn't even look at them, how do you have any idea
> 	it's going to work for them?
> 

I did look at them.

> All that needs to be supplied is sufficient evidence, collected
> from 20 spots around the VM (arch code), and for that matter, in
> summary form ("I audited all architectures"). This should not be in

I audited and verified that i386 and x86-64 work.

I didn't audit any other arch (although I looked at many) at
this stage.

> the form of a lie, not to imply you would do that. The sparc64 analysis
> you gave is actually somewhat off but it doesn't really matter so long
> as there's actual diligence instead of simultaneous claims of
> sufficiency and non-diligence.
> 


Hmm. The sparc64 patch will actually have a slight problem in
the generic code too FWIW, must think about how to fix it.

... but what part of the sparc64 analysis I gave is off?

> I am not even looking at the code. I have my own work to do. I
> respectfully ask that when you do your own, you exercise the kind
> of diligence I described above as opposed to the kind of affiar you
> described in your announcement.
> 

Yeah I try to do just that. I don't know what it was I said in the
announcement that got under your skin. Presumably it is still kosher
to request comments on patches that may not immediately work for all
architectures, and have some known brokenness?

I was actually more interested in technical feedback and comments
about the direction of the patch rather than being told to audit
everything at this stage... You can sleep easy that I'll be pushing
shit up a hill to get this thing merged even when everything *is*
audited and verified to work correctly :|


But there is a bit of private dialogue among interested parties,
I'll keep the topic off the list until we've established a bit more
of a consensus about things.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
