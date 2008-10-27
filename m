Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9RM9aEs031894
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 18:09:36 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9RM9aaj123118
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 18:09:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9RM9akA004395
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 18:09:36 -0400
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
	restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <490637D8.4080404@cs.columbia.edu>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	 <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>
	 <20081021124130.a002e838.akpm@linux-foundation.org>
	 <20081021202410.GA10423@us.ibm.com>	<48FE82DF.6030005@cs.columbia.edu>
	 <20081022152804.GA23821@us.ibm.com>	<48FF4EB2.5060206@cs.columbia.edu>
	 <87tzayh27r.wl%peter@chubb.wattle.id.au> <49059FED.4030202@cs.columbia.edu>
		 <1225125752.12673.79.camel@nimitz> <4905F648.4030402@cs.columbia.edu>
	 <1225140705.5115.40.camel@enoch> <490637D8.4080404@cs.columbia.edu>
Content-Type: text/plain
Date: Mon, 27 Oct 2008 15:09:33 -0700
Message-Id: <1225145373.12673.125.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Matt Helsley <matthltc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, mingo@elte.hu, torvalds@linux-foundation.org, Peter Chubb <peterc@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-10-27 at 17:51 -0400, Oren Laadan wrote:
> >       Instead, how about a flag to sys_checkpoint() -- DO_RISKY_CHECKPOINT --
> > which checkpoints despite !may_checkpoint?
> 
> I also agree with Matt - so we have a quorum :)
> 
> so just to clarify: sys_checkpoint() is to fail (with what error ?) if the
> deny-checkpoint test fails.
> 
> however, if the user is risky, she can specify CR_CHECKPOINT_RISKY to force
> an attempt to checkpoint as is.

This sounds like an awful lot of policy to determine *inside* the
kernel.  Everybody is going to have a different definition of risky, so
this scheme will work for approximately 5 minutes until it gets
patched. :)

Is it possible to enhance our interface such that users might have some
kind of choice on these matters?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
