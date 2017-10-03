Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0BAF6B025F
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:11:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u78so8164050wmd.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:11:19 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c92si6354265edf.457.2017.10.03.08.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:11:18 -0700 (PDT)
Subject: Re: [PATCH v9 02/12] sparc64/mm: setting fields in deferred pages
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-3-pasha.tatashin@oracle.com>
 <20171003122823.mdzkhxs4xza7sb2w@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <3c410186-0af9-dae8-84eb-8f4d4651d355@oracle.com>
Date: Tue, 3 Oct 2017 11:10:35 -0400
MIME-Version: 1.0
In-Reply-To: <20171003122823.mdzkhxs4xza7sb2w@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

> 
> As you separated x86 and sparc patches doing essentially the same I
> assume David is going to take this patch?

Correct, I noticed that usually platform specific changes are done in 
separate patches even if they are small. Dave already Acked this patch. 
So, I do not think it should be separated from the rest of the patches 
when this projects goes into mm-tree.

> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
