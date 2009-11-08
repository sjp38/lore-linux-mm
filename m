Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6DBE46B0083
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 08:05:29 -0500 (EST)
Date: Sun, 8 Nov 2009 14:05:21 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
Message-ID: <20091108130521.GA29728@elte.hu>
References: <20091102092214.GB8933@elte.hu>
 <20091102160410.GF27911@redhat.com>
 <20091102161248.GB15423@elte.hu>
 <20091102162234.GH27911@redhat.com>
 <20091102162941.GC14544@elte.hu>
 <20091102174208.GJ27911@redhat.com>
 <20091108113654.GO11372@elte.hu>
 <4AF6BCE5.3030701@redhat.com>
 <20091108125135.GA13099@elte.hu>
 <4AF6C112.4010601@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AF6C112.4010601@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Fr??d??ric Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 11/08/2009 02:51 PM, Ingo Molnar wrote:
> >>Maybe we should generalize paravirt-ops patching in case if (x) f() is
> >>deemed too expensive.
> >Yes, that's a nice idea. We have quite a number of 'conditional
> >callbacks' in various critical paths that could be made lighter via such
> >a technique.
> >
> > It would also free new callbacks from the 'it increases overhead 
> > even if unused' criticism and made it easier to add them.
> 
> We can take the "immediate values" infrastructure as a first step. Has 
> that been merged?

No, there were doubts about whether patching in live instructions like 
that is safe on all CPU types.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
