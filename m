Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id F023C6B0062
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 20:30:39 -0500 (EST)
Message-ID: <50A4458E.5050601@infradead.org>
Date: Wed, 14 Nov 2012 17:29:50 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: balloon_compaction.c needs asm-generic/bug.h
References: <20121114163042.64f0c0495663331b9c2d60d6@canb.auug.org.au> <50A43E64.3040709@infradead.org> <alpine.DEB.2.00.1211141729050.4749@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211141729050.4749@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rafael Aquini <aquini@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 11/14/2012 05:29 PM, David Rientjes wrote:

> On Wed, 14 Nov 2012, Randy Dunlap wrote:
> 
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> Fix build when CONFIG_BUG is not enabled by adding header file
>> <asm-generic/bug.h>:
>>
>> mm/balloon_compaction.c: In function 'balloon_page_putback':
>> mm/balloon_compaction.c:243:3: error: implicit declaration of function '__WARN'
>>
> 
> This is fixed by 
> mm-introduce-a-common-interface-for-balloon-pages-mobility-fix-fix-fix.patch 
> in -mm which converts it to WARN_ON(1) which is the generic way to trigger 
> a warning.
> --


OK, thanks for the info.

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
