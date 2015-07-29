Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CA4AE6B0254
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:50:05 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so20386205wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:50:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 15si6710936wjx.108.2015.07.29.03.50.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 03:50:04 -0700 (PDT)
Subject: Re: [PATCH V5 0/7] Allow user to request memory to be locked on page
 fault
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <55B5F4FF.9070604@suse.cz> <20150727133555.GA17133@akamai.com>
 <55B63D37.20303@suse.cz> <20150727145409.GB21664@akamai.com>
 <20150728111725.GG24972@dhcp22.suse.cz> <20150728134942.GB2407@akamai.com>
 <20150729104532.GE15801@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B8AFD5.3030902@suse.cz>
Date: Wed, 29 Jul 2015 12:49:57 +0200
MIME-Version: 1.0
In-Reply-To: <20150729104532.GE15801@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 07/29/2015 12:45 PM, Michal Hocko wrote:
>> In a much less
>> likely corner case, it is not possible in the current setup to request
>> all current VMAs be VM_LOCKONFAULT and all future be VM_LOCKED.
> 
> Vlastimil has already pointed that out. MCL_FUTURE doesn't clear
> MCL_CURRENT. I was quite surprised in the beginning but it makes a
> perfect sense. mlockall call shouldn't lead into munlocking, that would
> be just weird. Clearing MCL_FUTURE on MCL_CURRENT makes sense on the
> other hand because the request is explicit about _current_ memory and it
> doesn't lead to any munlocking.

Yeah after more thinking it does make some sense despite the perceived
inconsistency, but it's definitely worth documenting properly. It also already
covers the usecase for munlockall2(MCL_FUTURE) which IIRC you had in the earlier
revisions...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
