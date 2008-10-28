Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9SIhGNN002463
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 14:43:16 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9SIhFPc1183950
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 14:43:15 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9SIgjag026454
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 12:42:46 -0600
Date: Tue, 28 Oct 2008 13:33:22 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
	restart
Message-ID: <20081028183322.GA13684@us.ibm.com>
References: <48FE82DF.6030005@cs.columbia.edu> <20081022152804.GA23821@us.ibm.com> <48FF4EB2.5060206@cs.columbia.edu> <87tzayh27r.wl%peter@chubb.wattle.id.au> <49059FED.4030202@cs.columbia.edu> <1225125752.12673.79.camel@nimitz> <4905F648.4030402@cs.columbia.edu> <1225140705.5115.40.camel@enoch> <490637D8.4080404@cs.columbia.edu> <1225145373.12673.125.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1225145373.12673.125.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, Peter Chubb <peterc@gelato.unsw.edu.au>, linux-mm@kvack.org, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Quoting Dave Hansen (dave@linux.vnet.ibm.com):
> On Mon, 2008-10-27 at 17:51 -0400, Oren Laadan wrote:
> > >       Instead, how about a flag to sys_checkpoint() -- DO_RISKY_CHECKPOINT --
> > > which checkpoints despite !may_checkpoint?
> > 
> > I also agree with Matt - so we have a quorum :)
> > 
> > so just to clarify: sys_checkpoint() is to fail (with what error ?) if the
> > deny-checkpoint test fails.
> > 
> > however, if the user is risky, she can specify CR_CHECKPOINT_RISKY to force
> > an attempt to checkpoint as is.
> 
> This sounds like an awful lot of policy to determine *inside* the
> kernel.  Everybody is going to have a different definition of risky, so
> this scheme will work for approximately 5 minutes until it gets
> patched. :)
> 
> Is it possible to enhance our interface such that users might have some
> kind of choice on these matters?

Well we could always just add a field to /proc/self/status, and let
userspace check that field (after freezing the task) for the
presence of CR_CHECKPOINT_RISKY and make up its own mind.

Though my preference is for simplicity - just refuse the checkpoint.
That way people might screan loudly enough for us to support the
features they want.  If we let them just bypass and hope for the
best that starts to dilute some of the intended effect of all this.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
