Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1501F6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 19:19:49 -0400 (EDT)
Received: by wibg7 with SMTP id g7so539432wib.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 16:19:48 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id hq9si9068479wjb.91.2015.03.20.16.19.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 16:19:47 -0700 (PDT)
Message-ID: <550CAB0A.8070402@nod.at>
Date: Sat, 21 Mar 2015 00:19:38 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: Introducing arch_remap hook
References: <cover.1426866405.git.ldufour@linux.vnet.ibm.com> <503499aae380db1c4673f146bcba6ad095021257.1426866405.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <503499aae380db1c4673f146bcba6ad095021257.1426866405.git.ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: cov@codeaurora.org, criu@openvz.org

Am 20.03.2015 um 16:53 schrieb Laurent Dufour:
> Some architecture would like to be triggered when a memory area is moved
> through the mremap system call.
> 
> This patch is introducing a new arch_remap mm hook which is placed in the
> path of mremap, and is called before the old area is unmapped (and the
> arch_unmap hook is called).
> 
> To no break the build, this patch adds the empty hook definition to the
> architectures that were not using the generic hook's definition.

Just wanted to point out that I like that new hook as UserModeLinux can benefit from it.
UML has the concept of stub pages where the UML host process can inject commands to guest processes.
Currently we play nasty games in the TLB code to make all this work.
arch_unmap() could make this stuff more clear and less error prone.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
