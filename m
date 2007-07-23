Date: Mon, 23 Jul 2007 13:34:50 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access
 of bad area during boot with DEBUG_SLAB=y
Message-ID: <20070723133450.3de91b33@schroedinger.engr.sgi.com>
In-Reply-To: <20070718095537.d344dc0a.akpm@linux-foundation.org>
References: <bug-8778-10286@http.bugzilla.kernel.org/>
	<20070718005253.942f0464.akpm@linux-foundation.org>
	<20070718083425.GA29722@gate.ebshome.net>
	<1184766070.3699.2.camel@zod.rchland.ibm.com>
	<20070718155940.GB29722@gate.ebshome.net>
	<20070718095537.d344dc0a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eugene Surovegin <ebs@ebshome.net>, linux-mm@kvack.org, Josh Boyer <jwboyer@linux.vnet.ibm.com>, bart.vanassche@gmail.com, netdev@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>, linuxppc-embedded@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jul 2007 09:55:37 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> hm.  It should be the case that providing SLAB_HWCACHE_ALIGN at
> kmem_cache_create() time will override slab-debugging's offsetting
> of the returned addresses.


That is true for SLUB but not in SLAB. SLAB has always ignored
SLAB_HWCACHE_ALIGN when debugging is on because of the issues involved
in placing the redzone values etc.  Could be fun to fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
