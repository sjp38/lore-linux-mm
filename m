Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 410DF6B0103
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 03:16:50 -0400 (EDT)
Message-ID: <4CB55CDD.9010908@kernel.org>
Date: Wed, 13 Oct 2010 10:16:45 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
References: <20101005185725.088808842@linux.com> <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com> <20101012182531.GH30667@csn.ul.ie>
In-Reply-To: <20101012182531.GH30667@csn.ul.ie>
Content-Type: multipart/mixed;
 boundary="------------070005060006040809030005"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070005060006040809030005
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

  On 10/12/10 9:25 PM, Mel Gorman wrote:
> On Wed, Oct 06, 2010 at 11:01:35AM +0300, Pekka Enberg wrote:
>> (Adding more people who've taken interest in slab performance in the
>> past to CC.)
>>
> I have not come even close to reviewing this yet but I made a start on
> putting it through a series of tests. It fails to build on ppc64
>
>    CC      mm/slub.o
> mm/slub.c:1477: warning: 'drain_alien_caches' declared inline after being called
> mm/slub.c:1477: warning: previous declaration of 'drain_alien_caches' was here

Can you try the attached patch to see if it fixes the problem?
> mm/slub.c: In function `alloc_shared_caches':
> mm/slub.c:1748: error: `cpu_info' undeclared (first use in this function)
> mm/slub.c:1748: error: (Each undeclared identifier is reported only once
> mm/slub.c:1748: error: for each function it appears in.)
> mm/slub.c:1748: warning: type defaults to `int' in declaration of `type name'
> mm/slub.c:1748: warning: type defaults to `int' in declaration of `type name'
> mm/slub.c:1748: warning: type defaults to `int' in declaration of `type name'
> mm/slub.c:1748: warning: type defaults to `int' in declaration of `type name'
> mm/slub.c:1748: error: invalid type argument of `unary *'
> make[1]: *** [mm/slub.o] Error 1
> make: *** [mm] Error 2
>
> I didn't look closely yet but cpu_info is an arch-specific variable.
> Checking to see if there is a known fix yet before setting aside time to
> dig deeper.
Yeah, cpu_info.llc_shared_map is an x86ism. Christoph?

             Pekka


--------------070005060006040809030005
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="0001-slub-Fix-drain_alien_cache-redeclaration.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-slub-Fix-drain_alien_cache-redeclaration.patch"


--------------070005060006040809030005--
