Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 472226B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 16:55:55 -0400 (EDT)
Date: Mon, 8 Apr 2013 13:55:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] mm: vmemmap: add vmemmap_verify check for hot-add
 node/memory case
Message-Id: <20130408135553.2f60518d923b6920bdf1931f@linux-foundation.org>
In-Reply-To: <CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com>
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
	<CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com, Arnd Bergmann <arnd@arndb.de>, tony@atomide.com, Ben Hutchings <ben@decadent.org.uk>, linux-arm-kernel@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Mon, 8 Apr 2013 11:40:11 -0700 Yinghai Lu <yinghai@kernel.org> wrote:

> On Mon, Apr 8, 2013 at 2:56 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
> > In hot add node(memory) case, vmemmap pages are always allocated from other
> > node,
> 
> that is broken, and should be fixed.
> vmemmap should be on local node even for hot add node.
> 

That would be nice.

I don't see much value in the added warnings, really.  Because there's
nothing the user can *do* about them, apart from a) stop using NUMA, b)
stop using memory hotplug, c) become a kernel MM developer or d) switch
to Windows.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
