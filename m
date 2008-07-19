Message-ID: <4881B303.2010407@cn.fujitsu.com>
Date: Sat, 19 Jul 2008 17:25:23 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm][splitlru][PATCH 0/3] munlock rework
References: <20080719084213.588795788@jp.fujitsu.com>
In-Reply-To: <20080719084213.588795788@jp.fujitsu.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

kosaki.motohiro@jp.fujitsu.com D'uA:
> old munlock processing of unevictable-lru use pagewalk.
> because get_user_pages() can't grab PROT_NONE page.
> 
> then, current -mm has two problem.
>   - build error on nommu machine
>   - runtime error on HIGHPTE machine.
> 
> So, I hope rework below concept
> 
> 	Old implementation
> 	   - use pagewalk
> 
> 	New implementation
> 	   - use __get_user_pages()
> 
> 
> I tested this patch on
>   IA64:                 >24H stress workload
>   x86_64:               ditto
>   x86_32 with HIGHPTE:  only half hour
> 
> 
> 
> Li-san, Could you please try to this patch on your 32bit machine?

I've tested this patchset, the bug disappeared and it survived the
ltp tests :) .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
