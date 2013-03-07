Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id BAD6F6B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 05:10:30 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so107198vbn.14
        for <linux-mm@kvack.org>; Thu, 07 Mar 2013 02:10:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <51373853.4010402@gmail.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
	<51373853.4010402@gmail.com>
Date: Thu, 7 Mar 2013 18:10:29 +0800
Message-ID: <CAA_GA1e8xNDDe4qjVHUpt6Ep7xdo-KBKEKbtrQ8v2GhOF+8HNA@mail.gmail.com>
Subject: Re: [PATCH V2 01/11] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: linux-mm@kvack.org, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>

Hi Ric,

On Wed, Mar 6, 2013 at 8:36 PM, Ric Mason <ric.masonn@gmail.com> wrote:
> On 03/06/2013 04:51 PM, Bob Liu wrote:
>>
>> From: Dan Magenheimer <dan.magenheimer@oracle.com>
>>
>> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
>> built/loaded as modules rather than built-in and enabled by a boot
>> parameter,
>> this patch provides "lazy initialization", allowing backends to register
>> to
>> frontswap even after swapon was run. Before a backend registers all calls
>> to init are recorded and the creation of tmem_pools delayed until a
>> backend
>> registers or until a frontswap store is attempted.
>
>
> You drop patch 0/11, why? Where is the changelog?
>

Sorry for my mistake,  i forgot to generate patch 0/11.
Since Andrew has already merge this series, i just add some comment here.

Below four patches in V1 will cause compile error if not define
CONFIG_FRONTSWAP/CLEANCACHE
frontswap: Use static_key instead of frontswap_enabled and frontswap_ops
frontswap: Remove the check for frontswap_enabled.
cleancache: Use static_key instead of cleancache_ops and cleancache_enabled.
cleancache: Remove the check for cleancache_enabled.

In V2
[PATCH V2 03/11] mm: frontswap: cleanup code
[PATCH V2 07/11] mm: cleancache: clean up cleancache_enabled
will fix the compile error and cleanup the code.

Now static_key was dropped which may cause some race in future if
module unload was supported.
I'll continue to update it base on -mm tree, so other not related
patches in this series don't need to be resend again.

V2 also fix some checkpatch error.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
