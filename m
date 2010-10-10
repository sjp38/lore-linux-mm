Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E4A586B0071
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 03:30:56 -0400 (EDT)
Date: Sun, 10 Oct 2010 09:30:41 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is
 swapped out.
Message-ID: <20101010073041.GK2397@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-3-git-send-email-gleb@redhat.com>
 <4CAD97D0.70100@redhat.com>
 <20101007174716.GD2397@redhat.com>
 <4CB0B4BA.5010901@redhat.com>
 <4CB0B52E.90806@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CB0B52E.90806@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Sat, Oct 09, 2010 at 08:32:14PM +0200, Avi Kivity wrote:
>  On 10/09/2010 08:30 PM, Avi Kivity wrote:
> >>So that "info cpu" will interfere with apf? Migration should work
> >>in regular way. apf state should not be migrated since it has no meaning
> >>on the destination. I'll make sure synthetic halt state will not
> >>interfere with migration.
> >
> >
> >If you deliver an apf, the guest expects a completion.
> >
> 
> btw, the token generation scheme resets as well.  Draining the queue
> fixes that as well.
> 
I don't see what's there to fix. Can you explain what problem you see in
the way current code works?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
