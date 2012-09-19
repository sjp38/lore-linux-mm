Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 1DE556B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 20:14:17 -0400 (EDT)
Date: Tue, 18 Sep 2012 17:20:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: qemu-kvm loops after kernel udpate
Message-Id: <20120918172029.b5425a40.akpm@linux-foundation.org>
In-Reply-To: <20120919100034.ceaee306e24e00cdf6f1e92e@canb.auug.org.au>
References: <504F7ED8.1030702@suse.cz>
	<20120911190303.GA3626@amt.cnet>
	<504F93F1.2060005@suse.cz>
	<50504299.2050205@redhat.com>
	<50504439.3050700@suse.cz>
	<5050453B.6040702@redhat.com>
	<5050D048.4010704@suse.cz>
	<5051AE8B.7090904@redhat.com>
	<5058CE2F.7030302@suse.cz>
	<20120918124646.02aaee4f.akpm@linux-foundation.org>
	<20120919100034.ceaee306e24e00cdf6f1e92e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Jiri Slaby <jslaby@suse.cz>, Avi Kivity <avi@redhat.com>, Jiri Slaby <jirislaby@gmail.com>, Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Haggai Eran <haggaie@mellanox.com>, linux-mm@kvack.org, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

On Wed, 19 Sep 2012 10:00:34 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Tue, 18 Sep 2012 12:46:46 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > hm, thanks.  This will probably take some time to resolve so I think
> > I'll drop
> > 
> > mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock.patch
> > mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix.patch
> > mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix-fix.patch
> > mm-wrap-calls-to-set_pte_at_notify-with-invalidate_range_start-and-invalidate_range_end.patch
> 
> Should I attempt to remove these from the akpm tree in linux-next today?

That would be best - there's no point in having people test (and debug)
dead stuff.

> Or should I just wait for a new mmotm?

You could be brave and test http://ozlabs.org/~akpm/mmots/ for me :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
