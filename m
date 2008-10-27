Message-ID: <49059FED.4030202@cs.columbia.edu>
Date: Mon, 27 Oct 2008 07:03:09 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint	restart
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>	<1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>	<20081021124130.a002e838.akpm@linux-foundation.org>	<20081021202410.GA10423@us.ibm.com>	<48FE82DF.6030005@cs.columbia.edu>	<20081022152804.GA23821@us.ibm.com>	<48FF4EB2.5060206@cs.columbia.edu> <87tzayh27r.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87tzayh27r.wl%peter@chubb.wattle.id.au>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, tglx@linutronix.de, dave@linux.vnet.ibm.com, mingo@elte.hu, hpa@zytor.com, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>


Peter Chubb wrote:
>>>>>> "Oren" == Oren Laadan <orenl@cs.columbia.edu> writes:
> 
> 
> Oren> Nope, since we will fail to restart in many cases. We will need
> Oren> a way to move from caller's credentials to saved credentials,
> Oren> and even from caller's credentials to privileged credentials
> Oren> (e.g. to reopen a file that was created by a setuid program
> Oren> prior to dropping privileges).
> 
> You can't necessarily tell the difference between this and revocation
> of privilege.  For most security models, it must be possible to change
> the permissions on the file, and then the restart should fail.
> 
> In our implementation, we simply refused to checkpoint setid programs.

True. And this works very well for HPC applications.

However, it doesn't work so well for server applications, for instance.

Also, you could use file system snapshotting to ensure that the file
system view does not change, and still face the same issue.

So I'm perfectly ok with deferring this discussion to a later time :)

Oren.

> --
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
