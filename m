Message-ID: <46152099.7060005@redhat.com>
Date: Thu, 05 Apr 2007 12:15:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <4614A5CC.5080508@redhat.com> <20070405094504.GM355@devserv.devel.redhat.com>
In-Reply-To: <20070405094504.GM355@devserv.devel.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Jakub Jelinek wrote:

> +	/* FIXME: POSIX says that MADV_DONTNEED cannot throw away data. */
>  	case MADV_DONTNEED:
> +	case MADV_FREE:
>  		error = madvise_dontneed(vma, prev, start, end);
>  		break;
>  
> I think you should only use the new behavior for madvise MADV_FREE, not for
> MADV_DONTNEED. 

I will.  However, we need to double-use MADV_DONTNEED in this
patch for now, so Ulrich's test glibc can be used easily :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
