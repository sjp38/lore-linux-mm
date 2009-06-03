Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 40E6B5F0001
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:11:39 -0400 (EDT)
Message-ID: <4A26CAD8.5070901@redhat.com>
Date: Wed, 03 Jun 2009 15:11:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change ZERO_SIZE_PTR
 to point at unmapped space)
References: <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com> <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <20090603182949.5328d411@lxorguk.ukuu.org.uk> <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain> <20090603180037.GB18561@oblivion.subreption.com> <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain> <20090603183939.GC18561@oblivion.subreption.com> <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain> <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain> <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> We could just move the check for mmap_min_addr out from
> CONFIG_SECURITY?
> 
> 
> Use mmap_min_addr indepedently of security models
> 
> This patch removes the dependency of mmap_min_addr on CONFIG_SECURITY.
> It also sets a default mmap_min_addr of 4096.
> 
> mmapping of addresses below 4096 will only be possible for processes
> with CAP_SYS_RAWIO.
> 
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
