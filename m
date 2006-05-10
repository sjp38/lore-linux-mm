From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: cleanup swap unused warning
Date: Wed, 10 May 2006 21:56:07 +1000
References: <200605102132.41217.kernel@kolivas.org> <20060510043834.70f40ddc.akpm@osdl.org> <200605102146.26080.kernel@kolivas.org>
In-Reply-To: <200605102146.26080.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200605102156.07929.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 May 2006 21:46, Con Kolivas wrote:
> On Wednesday 10 May 2006 21:38, Andrew Morton wrote:
> > We have __attribute_used__, which hides a gcc oddity.
>
> I tried that.
>
> In file included from arch/i386/mm/pgtable.c:11:
> include/linux/swap.h:82: warning: a??__used__a?? attribute ignored
> In file included from include/linux/suspend.h:8,
>                  from init/do_mounts.c:7:
> include/linux/swap.h:82: warning: a??__used__a?? attribute ignored
> In file included from arch/i386/mm/init.c:22:
> include/linux/swap.h:82: warning: a??__used__a?? attribute ignored
>   AS      arch/i386/kernel/vsyscall-sysenter.o
>
> etc..
>
> and doesn't fix the warning in vmscan.c. __attribute_used__ is handled
> differently by gcc4 it seems (this is 4.1.0)

in compiler-gcc3.h
#if __GNUC_MINOR__ >= 3
# define __attribute_used__     __attribute__((__used__))
#else
# define __attribute_used__     __attribute__((__unused__))
#endif

and in compiler-gcc4.h
#define __attribute_used__      __attribute__((__used__))

it looks like the pre gcc3.3 version is suited here or I'm misusing the 
__attribute_used__ extension somehow.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
