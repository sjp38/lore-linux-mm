Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 33A726B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 17:19:47 -0400 (EDT)
Date: Fri, 8 Jun 2012 14:19:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Resend PATCH v2] mm: Fix slab->page _count corruption.
Message-Id: <20120608141945.4df63d95.akpm@linux-foundation.org>
In-Reply-To: <CALnjE+rdvdj=XXd7iCYzL_BUGYsLQTM1mYRay+0q2iFxqiDqSw@mail.gmail.com>
References: <1338405610-1788-1-git-send-email-pshelar@nicira.com>
	<20120608131045.90708bda.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1206081514130.4213@router.home>
	<CALnjE+rdvdj=XXd7iCYzL_BUGYsLQTM1mYRay+0q2iFxqiDqSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin Shelar <pshelar@nicira.com>
Cc: Christoph Lameter <cl@linux.com>, penberg@kernel.org, aarcange@redhat.com, linux-mm@kvack.org, abhide@nicira.com

On Fri, 8 Jun 2012 13:23:56 -0700
Pravin Shelar <pshelar@nicira.com> wrote:

> On Fri, Jun 8, 2012 at 1:15 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Fri, 8 Jun 2012, Andrew Morton wrote:
> >
> >> OK. __I assume this bug has been there for quite some time.
> >
> > Well the huge pages refcount tricks caused the issue.
> >
> >> How serious is it? __Have people been reporting it in real workloads?
> >> How to trigger it? __IOW, does this need -stable backporting?
> >
> > Possibly.
> 
> If this patch is getting back-ported then we shld also do same for
> 5bf5f03c271907978 (mm: fix slab->page flags corruption) which fixes
> other issue related to slub  and huge page sharing.

Well I don't know if either are getting backported yet.

To decide that we would have to understand the end-user impact of the
bug(s).  Please tell us?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
