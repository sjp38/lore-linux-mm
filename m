Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 241346B0069
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:21:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h13so9091832qke.6
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:21:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u7si4765371qkh.465.2017.10.03.08.21.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:21:33 -0700 (PDT)
Subject: Re: [PATCH v9 04/12] sparc64: simplify vmemmap_populate
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-5-pasha.tatashin@oracle.com>
 <20171003125940.6d5fyhwx2lkzxn67@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <8104d3da-7905-e888-eb6a-223ecf237ca1@oracle.com>
Date: Tue, 3 Oct 2017 11:20:53 -0400
MIME-Version: 1.0
In-Reply-To: <20171003125940.6d5fyhwx2lkzxn67@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com


> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
