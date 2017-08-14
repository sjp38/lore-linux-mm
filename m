Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 463CD6B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:35:54 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id q13so41736486uaf.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:35:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l196si3422100vka.163.2017.08.14.06.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 06:35:53 -0700 (PDT)
Subject: Re: [v6 04/15] mm: discard memblock data later
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
 <6366171f-1a30-2faa-d776-01983fcb5a00@oracle.com>
 <20170811160436.GS30811@dhcp22.suse.cz>
 <a63eb223-455f-ae57-122f-7b2655e3de26@oracle.com>
 <20170814113652.GF19063@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <3c223cac-68f8-f810-38dd-4ff580048e63@oracle.com>
Date: Mon, 14 Aug 2017 09:35:16 -0400
MIME-Version: 1.0
In-Reply-To: <20170814113652.GF19063@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

>> OK, I will post it separately. No it does not depend on the rest, but the
>> reset depends on this. So, I am not sure how to enforce that this comes
>> before the rest.
> 
> Andrew will take care of that. Just make it explicit that some of the
> patch depends on an earlier work when reposting.

Ok.

>> Yes, they said that the problem was bisected down to this patch. Do you know
>> if there is a way to submit a patch to this test robot?
> 
> You can ask them for re testing with an updated patch by replying to
> their report. ANyway I fail to see how the change could lead to this
> patch.

I have already done that. Anyway, I think it is unrelated. I have used 
their scripts to test the patch alone, with number of elements in 
memblock array reduced down to 4. Verified that my freeing code is 
called, and never hit the problem that they reported.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
