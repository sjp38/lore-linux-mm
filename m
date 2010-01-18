Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 85CF46B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 03:50:39 -0500 (EST)
Date: Mon, 18 Jan 2010 10:50:22 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
Message-ID: <20100118085022.GA30698@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
 <1262700774-1808-5-git-send-email-gleb@redhat.com>
 <1263490267.4244.340.camel@laptop>
 <20100117144411.GI31692@redhat.com>
 <4B541D08.9040802@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B541D08.9040802@zytor.com>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 12:34:16AM -0800, H. Peter Anvin wrote:
> On 01/17/2010 06:44 AM, Gleb Natapov wrote:
> >On Thu, Jan 14, 2010 at 06:31:07PM +0100, Peter Zijlstra wrote:
> >>On Tue, 2010-01-05 at 16:12 +0200, Gleb Natapov wrote:
> >>>Allow paravirtualized guest to do special handling for some page faults.
> >>>
> >>>The patch adds one 'if' to do_page_fault() function. The call is patched
> >>>out when running on physical HW. I ran kernbech on the kernel with and
> >>>without that additional 'if' and result were rawly the same:
> >>
> >>So why not program a different handler address for the #PF/#GP faults
> >>and avoid the if all together?
> >I would gladly use fault vector reserved by x86 architecture, but I am
> >not sure Intel will be happy about it.
> >
> 
> That's what it's there for... see Peter Z.'s response.
> 
Do you mean I can use one of exception vectors reserved by Intel
(20-31)? What Peter Z says is that I can register my own handler for
#PF and avoid the 'if' in non PV case as far as I understand him.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
