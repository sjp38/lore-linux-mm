Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DEDA36B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 21:31:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v82so1895277pgb.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 18:31:20 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j128si11677275pgc.639.2017.09.14.18.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 18:31:19 -0700 (PDT)
Subject: Re: [PATCH v8 10/11] arm64/kasan: explicitly zero kasan shadow memory
References: <20170914223517.8242-1-pasha.tatashin@oracle.com>
 <20170914223517.8242-11-pasha.tatashin@oracle.com>
 <20170915011035.GA6936@remoulade>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <c76f72fc-21ed-62d0-014e-8509c0374f96@oracle.com>
Date: Thu, 14 Sep 2017 21:30:28 -0400
MIME-Version: 1.0
In-Reply-To: <20170915011035.GA6936@remoulade>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Mark,

Thank you for looking at this. We can't do this because page table is 
not set until cpu_replace_ttbr1() is called. So, we can't do memset() on 
this memory until then.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
