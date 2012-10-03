Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id F121B6B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:15:25 -0400 (EDT)
Date: Wed, 3 Oct 2012 14:15:24 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slab: release slab_mutex earlier in kmem_cache_destroy()
 (was Re: Lockdep complains about commit 1331e7a1bb ("rcu: Remove _rcu_barrier()
 dependency on __stop_machine()"))
In-Reply-To: <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz>
Message-ID: <0000013a26fb253a-fb5df733-ad41-47c1-af1d-3d6739e417de-000000@email.amazonses.com>
References: <alpine.LNX.2.00.1210021810350.23544@pobox.suse.cz> <20121002170149.GC2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210022324050.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022331130.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022356370.23544@pobox.suse.cz>
 <20121002233138.GD2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030142570.23544@pobox.suse.cz> <20121003001530.GF2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 3 Oct 2012, Jiri Kosina wrote:

> How about the patch below? Pekka, Christoph, please?

Looks fine for -stable. For upstream there is going to be a move to
slab_common coming in this merge period. We would need a fix against -next
or Pekka's tree too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
