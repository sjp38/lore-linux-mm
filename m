Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 721D56B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 08:34:05 -0400 (EDT)
Date: Tue, 21 May 2013 13:18:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 10/10] kernel: might_fault does not imply might_sleep
Message-ID: <20130521111818.GI26912@twins.programming.kicks-ass.net>
References: <cover.1368702323.git.mst@redhat.com>
 <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
 <20130516184041.GP19669@dyad.programming.kicks-ass.net>
 <20130519093526.GD19883@redhat.com>
 <1368966844.6828.111.camel@gandalf.local.home>
 <20130519133418.GA24381@redhat.com>
 <1368979579.6828.114.camel@gandalf.local.home>
 <20130519164009.GA2434@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130519164009.GA2434@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Sun, May 19, 2013 at 07:40:09PM +0300, Michael S. Tsirkin wrote:
> OK I get it. So let me correct myself. The simple code
> that does something like this under a spinlock:
> >       preempt_disable
> >       pagefault_disable
> >       error = copy_to_user
> >       pagefault_enable
> >       preempt_enable
> >
> is not doing anything wrong and should not get a warning,
> as long as error is handled correctly later.
> Right?

Indeed, but I don't get the point of the preempt_{disable,enable}()
here. Why does it have to disable preemption explicitly here? I thought
all you wanted was to avoid the pagefault handler and make it do the
exception table thing; for that pagefault_disable() is sufficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
