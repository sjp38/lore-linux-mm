Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 194906B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 14:40:16 -0400 (EDT)
Received: by mail-ia0-f174.google.com with SMTP id b35so5569598iac.33
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 11:40:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
Date: Mon, 8 Apr 2013 11:40:11 -0700
Message-ID: <CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: vmemmap: add vmemmap_verify check for hot-add
 node/memory case
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com, Arnd Bergmann <arnd@arndb.de>, tony@atomide.com, Ben Hutchings <ben@decadent.org.uk>, linux-arm-kernel@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Mon, Apr 8, 2013 at 2:56 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
> In hot add node(memory) case, vmemmap pages are always allocated from other
> node,

that is broken, and should be fixed.
vmemmap should be on local node even for hot add node.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
