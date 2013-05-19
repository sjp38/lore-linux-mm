Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id E9BFB6B0002
	for <linux-mm@kvack.org>; Sun, 19 May 2013 12:06:23 -0400 (EDT)
Message-ID: <1368979579.6828.114.camel@gandalf.local.home>
Subject: Re: [PATCH v2 10/10] kernel: might_fault does not imply might_sleep
From: Steven Rostedt <rostedt@goodmis.org>
Date: Sun, 19 May 2013 12:06:19 -0400
In-Reply-To: <20130519133418.GA24381@redhat.com>
References: <cover.1368702323.git.mst@redhat.com>
	 <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
	 <20130516184041.GP19669@dyad.programming.kicks-ass.net>
	 <20130519093526.GD19883@redhat.com>
	 <1368966844.6828.111.camel@gandalf.local.home>
	 <20130519133418.GA24381@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Sun, 2013-05-19 at 16:34 +0300, Michael S. Tsirkin wrote:

> Right but we need to keep it working on upstream as well.
> If I do preempt_enable under a spinlock upstream won't it
> try to sleep under spinlock?

No it wont. A spinlock calls preempt_disable implicitly, and a
preempt_enable() will not schedule unless preempt_count is zero, which
it wont be under a spinlock.

If it did, there would be lots of bugs all over the place because this
is done throughout the kernel (a preempt_enable() under a spinlock).

In other words, don't ever use preempt_enable_no_resched().

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
