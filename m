Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7BA6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 11:12:49 -0400 (EDT)
Message-ID: <4C470E69.7020900@kernel.org>
Date: Wed, 21 Jul 2010 17:12:41 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: Dead Config in mm/percpu.c
References: <861vaxjij8.fsf@peer.zerties.org>
In-Reply-To: <861vaxjij8.fsf@peer.zerties.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Dietrich <stettberger@dokucode.de>
Cc: David Howells <dhowells@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/21/2010 11:22 AM, Christian Dietrich wrote:
> Hi all!
>        
>         As part of the VAMOS[0] research project at the University of
> Erlangen we are looking at multiple integrity errors in linux'
> configuration system.
> 
>         I've been running a check on the mm/ sourcetree for
> config Items not defined in Kconfig and found 1 such case. Sourcecode
> blocks depending on these Items are not reachable from a vanilla
> kernel -- dead code. I've seen such dead blocks made on purpose
> e.g. while integrating new features into the kernel but generally
> they're just useless.
> 
> We found, that CONFIG_NEED_PER_CPU_KM is a dead symbol, so it isn't defined
> anywhere. Cause of that the percpu_km.c is never included anywhere. Is
> this a intended dead symbol, for use in out of tree development, or is
> this just an error?

Oh, it's new code waiting to be used.  It's for cases where SMP is
used w/o MMU.  IIRC, it was blackfin.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
