Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 18C336B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 16:37:13 -0400 (EDT)
Date: Mon, 26 Aug 2013 16:37:02 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130826203702.GA15407@redhat.com>
References: <20130819231836.GD14369@redhat.com>
 <CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
 <20130821204901.GA19802@redhat.com>
 <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
 <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <20130826201846.GA23724@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826201846.GA23724@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Aug 27, 2013 at 12:18:46AM +0400, Cyrill Gorcunov wrote:
 > On Mon, Aug 26, 2013 at 03:08:22PM -0400, Dave Jones wrote:
 > > On Mon, Aug 26, 2013 at 11:45:53AM +0800, Hillf Danton wrote:
 > >  > On Fri, Aug 23, 2013 at 11:53 AM, Dave Jones <davej@redhat.com> wrote:
 > >  > >
 > >  > > It actually seems worse, seems I can trigger it even easier now, as if
 > >  > > there's a leak.
 > >  > >
 > >  > Can you please try the new fix for TLB flush?
 > >  > 
 > >  > commit  2b047252d087be7f2ba
 > >  > Fix TLB gather virtual address range invalidation corner cases
 > > 
 > > No luck.
 > 
 > Hi Dave, could you please put your .config somewhere so i would try
 > to repeat this problem? (i've tried trinity with -C64 but it didn't
 > trigger the issue).

http://paste.fedoraproject.org/34944/77549285
machine I'm using has 8gb ram, 8gb swap, and 4 cores.

Try adding the -C64 to the invocation in scripts/test-multi.sh,
and perhaps up'ing the NR_PROCESSES variable there too.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
