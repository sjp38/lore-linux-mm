Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3C16B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 10:11:49 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s18so18231321qks.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 07:11:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v126si831276qkc.268.2017.08.11.07.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 07:11:48 -0700 (PDT)
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz> <1502117991.6577.13.camel@redhat.com>
 <20170810130531.GS23863@dhcp22.suse.cz>
 <CAAF6GDc2hsj-XJj=Rx2ZF6Sh3Ke6nKewABXfqQxQjfDd5QN7Ug@mail.gmail.com>
 <20170810153639.GB23863@dhcp22.suse.cz>
 <CAAF6GDeno6RpHf1KORVSxUL7M-CQfbWFFdyKK8LAWd_6PcJ55Q@mail.gmail.com>
 <20170810170144.GA987@dhcp22.suse.cz>
 <CAAF6GDdFjS612mx1TXzaVk1J-Afz9wsAywTEijO2TG4idxabiw@mail.gmail.com>
 <20170811140653.GO30811@dhcp22.suse.cz>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <c8cda773-b28d-f35f-7f18-6735584cb173@redhat.com>
Date: Fri, 11 Aug 2017 16:11:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170811140653.GO30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Colm_MacC=c3=a1rthaigh?= <colm@allcosts.net>
Cc: Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Rik van Riel <riel@redhat.com>, Will Drewry <wad@chromium.org>, akpm@linux-foundation.org, dave.hansen@intel.com, kirill@shutemov.name, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@amacapital.net, mingo@kernel.org

On 08/11/2017 04:06 PM, Michal Hocko wrote:

> I am sorry to look too insisting here (I have still hard time to reconcile
> myself with the madvise (ab)use) but if we in fact want minherit like
> interface why don't we simply add minherit and make the code which wants
> to use that interface easier to port? Is the only reason that hooking
> into madvise is less code? If yes is that a sufficient reason to justify
> the (ab)use of madvise? If there is a general consensus on that part I
> will shut up and won't object anymore. Arguably MADV_DONTFORK would fit
> into minherit API better as well.

It does, OpenBSD calls it MAP_INHERIT_NONE.

Could you implement MAP_INHERIT_COPY and MAP_INHERIT_SHARE as well?  Or
is changing from MAP_SHARED to MAP_PRIVATE and back impossible?

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
