Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 44C286B005A
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 16:46:01 -0500 (EST)
Date: Sat, 22 Dec 2012 19:45:52 -0200
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [Qemu-devel] [RFC 3/3] virtio-balloon: add auto-ballooning
 support
Message-ID: <20121222194552.55c9a97d@doriath>
In-Reply-To: <24E144B8C0207547AD09C467A8259F75578B8BD8@lisa.maurer-it.com>
References: <1355861815-2607-1-git-send-email-lcapitulino@redhat.com>
	<1355861815-2607-4-git-send-email-lcapitulino@redhat.com>
	<20121218225330.GA28297@lizard.mcd00620.sjc.wayport.net>
	<20121219093039.51831f6f@doriath.home>
	<24E144B8C0207547AD09C467A8259F75578B8BD8@lisa.maurer-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dietmar Maurer <dietmar@proxmox.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "aquini@redhat.com" <aquini@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mgorman@suse.de>, "agl@us.ibm.com" <agl@us.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "kirill@shutemov.name" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 20 Dec 2012 05:24:12 +0000
Dietmar Maurer <dietmar@proxmox.com> wrote:

> > > Wow, you're fast! And I'm glad that it works for you, so we have two
> > > full-featured mempressure cgroup users already.
> > 
> > Thanks, although I think we need more testing to be sure this does what we
> > want. I mean, the basic mechanics does work, but my testing has been very
> > light so far.
> 
> Is it possible to assign different weights for different VMs, something like the vmware 'shares' setting?

This series doesn't have the "weight" concept, it has auto-balloon-level and
auto-balloon-granularity. The former allows you to choose which type of
kernel low-mem level you want auto-inflate to trigger. The latter allows you
to say by how much the balloon should grow (as a percentage of the guest's
current memory).

Both of them are per VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
