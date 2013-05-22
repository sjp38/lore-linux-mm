Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 43BEF6B0088
	for <linux-mm@kvack.org>; Wed, 22 May 2013 06:19:23 -0400 (EDT)
Date: Wed, 22 May 2013 12:19:16 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 00/10] uaccess: better might_sleep/might_fault behavior
Message-ID: <20130522101916.GM18810@twins.programming.kicks-ass.net>
References: <cover.1368702323.git.mst@redhat.com>
 <201305221125.36284.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201305221125.36284.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Wed, May 22, 2013 at 11:25:36AM +0200, Arnd Bergmann wrote:
> Calling might_fault() for every __get_user/__put_user is rather expensive
> because it turns what should be a single instruction (plus fixup) into an
> external function call.

We could hide it all behind CONFIG_DEBUG_ATOMIC_SLEEP just like
might_sleep() is. I'm not sure there's a point to might_fault() when
might_sleep() is a NOP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
