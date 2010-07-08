Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9EC926006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 09:36:07 -0400 (EDT)
Date: Thu, 8 Jul 2010 16:35:42 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v4 11/12] Let host know whether the guest can handle
 async PF in non-userspace context.
Message-ID: <20100708133542.GX4689@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
 <1278433500-29884-12-git-send-email-gleb@redhat.com>
 <4C3553E2.7020607@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C3553E2.7020607@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 08, 2010 at 12:28:18AM -0400, Rik van Riel wrote:
> On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> >If guest can detect that it runs in non-preemptable context it can
> >handle async PFs at any time, so let host know that it can send async
> >PF even if guest cpu is not in userspace.
> 
> The code looks correct.  One question though - is there a
> reason to implement the userspace-only async PF path at
> all, since the handling of async PF in non-userspace context
> is introduced simultaneously?
> 
Guest userspace-only async PF handling is added in patch 4 and
non-userspace is added in patch 10. It is done for easy reviewing.
If I implement everything in one patch it will be harder to see why
things are done the way they are IMHO.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
