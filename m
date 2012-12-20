Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A276E6B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 00:24:18 -0500 (EST)
From: Dietmar Maurer <dietmar@proxmox.com>
Subject: RE: [Qemu-devel] [RFC 3/3] virtio-balloon: add auto-ballooning
	support
Date: Thu, 20 Dec 2012 05:24:12 +0000
Message-ID: <24E144B8C0207547AD09C467A8259F75578B8BD8@lisa.maurer-it.com>
References: <1355861815-2607-1-git-send-email-lcapitulino@redhat.com>
	<1355861815-2607-4-git-send-email-lcapitulino@redhat.com>
	<20121218225330.GA28297@lizard.mcd00620.sjc.wayport.net>
 <20121219093039.51831f6f@doriath.home>
In-Reply-To: <20121219093039.51831f6f@doriath.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>, Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Michal Hocko <mhocko@suse.cz>, "aquini@redhat.com" <aquini@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mgorman@suse.de>, "agl@us.ibm.com" <agl@us.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "kirill@shutemov.name" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>

> > Wow, you're fast! And I'm glad that it works for you, so we have two
> > full-featured mempressure cgroup users already.
>=20
> Thanks, although I think we need more testing to be sure this does what w=
e
> want. I mean, the basic mechanics does work, but my testing has been very
> light so far.

Is it possible to assign different weights for different VMs, something lik=
e the vmware 'shares' setting?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
