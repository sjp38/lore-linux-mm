Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C3DFA6B01AC
	for <linux-mm@kvack.org>; Sun,  4 Jul 2010 12:51:03 -0400 (EDT)
Message-ID: <4C30BBF0.1030801@cs.helsinki.fi>
Date: Sun, 04 Jul 2010 19:50:56 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH V2] slab: fix caller tracking on !CONFIG_DEBUG_SLAB &&
 CONFIG_TRACING
References: <alpine.DEB.2.00.1004090947030.10992@chino.kir.corp.google.com> <1277891842-18898-1-git-send-email-dfeng@redhat.com> <alpine.DEB.2.00.1006301307001.27676@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1006301307001.27676@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Xiaotian Feng <dfeng@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Monakhov <dmonakhov@openvz.org>, Catalin Marinas <catalin.marinas@arm.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Wed, 30 Jun 2010, Xiaotian Feng wrote:
> 
>> In slab, all __xxx_track_caller is defined on CONFIG_DEBUG_SLAB || CONFIG_TRACING,
>> thus caller tracking function should be worked for CONFIG_TRACING. But if
>> CONFIG_DEBUG_SLAB is not set, include/linux/slab.h will define xxx_track_caller to
>> __xxx() without consideration of CONFIG_TRACING. This will break the caller tracking
>> behaviour then.
>>
>> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
>> Cc: Christoph Lameter <cl@linux-foundation.org>
>> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
>> Cc: Matt Mackall <mpm@selenic.com>
>> Cc: Vegard Nossum <vegard.nossum@gmail.com>
>> Cc: Dmitry Monakhov <dmonakhov@openvz.org>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: David Rientjes <rientjes@google.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
