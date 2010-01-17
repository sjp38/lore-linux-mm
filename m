Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C1D26B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 09:44:26 -0500 (EST)
Date: Sun, 17 Jan 2010 16:44:11 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
Message-ID: <20100117144411.GI31692@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
 <1262700774-1808-5-git-send-email-gleb@redhat.com>
 <1263490267.4244.340.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1263490267.4244.340.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 06:31:07PM +0100, Peter Zijlstra wrote:
> On Tue, 2010-01-05 at 16:12 +0200, Gleb Natapov wrote:
> > Allow paravirtualized guest to do special handling for some page faults.
> > 
> > The patch adds one 'if' to do_page_fault() function. The call is patched
> > out when running on physical HW. I ran kernbech on the kernel with and
> > without that additional 'if' and result were rawly the same:
> 
> So why not program a different handler address for the #PF/#GP faults
> and avoid the if all together?
I would gladly use fault vector reserved by x86 architecture, but I am
not sure Intel will be happy about it.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
