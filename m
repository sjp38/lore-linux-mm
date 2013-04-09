Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id DCB966B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:00:43 -0400 (EDT)
Message-ID: <516376B3.90207@cn.fujitsu.com>
Date: Tue, 09 Apr 2013 10:02:27 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] mm: vmemmap: add vmemmap_verify check for hot-add
 node/memory case
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com> <CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com>
In-Reply-To: <CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com, Arnd Bergmann <arnd@arndb.de>, tony@atomide.com, Ben Hutchings <ben@decadent.org.uk>, linux-arm-kernel@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Hi Yinghai,

On 04/09/2013 02:40 AM, Yinghai Lu wrote:
> On Mon, Apr 8, 2013 at 2:56 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
>> In hot add node(memory) case, vmemmap pages are always allocated from other
>> node,
> 
> that is broken, and should be fixed.
> vmemmap should be on local node even for hot add node.
> 

Have you ever sent any relative patchset on this, maybe we can run some test
on it ;-)

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
