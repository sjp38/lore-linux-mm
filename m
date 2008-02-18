From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 3/6] mmu_notifier: invalidate_page callbacks
Date: Mon, 18 Feb 2008 12:51:27 +1100
References: <20080215064859.384203497@sgi.com> <20080215064932.918191502@sgi.com> <20080215193736.9d6e7da3.akpm@linux-foundation.org>
In-Reply-To: <20080215193736.9d6e7da3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802181251.28813.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Saturday 16 February 2008 14:37, Andrew Morton wrote:
> On Thu, 14 Feb 2008 22:49:02 -0800 Christoph Lameter <clameter@sgi.com> 
wrote:
> > Two callbacks to remove individual pages as done in rmap code
> >
> > 	invalidate_page()
> >
> > Called from the inner loop of rmap walks to invalidate pages.
> >
> > 	age_page()
> >
> > Called for the determination of the page referenced status.
> >
> > If we do not care about page referenced status then an age_page callback
> > may be be omitted. PageLock and pte lock are held when either of the
> > functions is called.
>
> The age_page mystery shallows.

BTW. can this callback be called mmu_notifier_clear_flush_young? To
match the core VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
