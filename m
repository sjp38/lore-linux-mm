Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83E2B6B0387
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:12:04 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id g75so64783187ywb.0
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:12:04 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u62si337048ywa.431.2017.08.11.09.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:12:03 -0700 (PDT)
Subject: Re: [v6 13/15] mm: stop zeroing memory during allocation in vmemmap
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-14-git-send-email-pasha.tatashin@oracle.com>
 <20170811130449.GL30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <16bdfd76-d28a-0732-9a15-29cc373e1236@oracle.com>
Date: Fri, 11 Aug 2017 12:11:24 -0400
MIME-Version: 1.0
In-Reply-To: <20170811130449.GL30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On 08/11/2017 09:04 AM, Michal Hocko wrote:
> On Mon 07-08-17 16:38:47, Pavel Tatashin wrote:
>> Replace allocators in sprase-vmemmap to use the non-zeroing version. So,
>> we will get the performance improvement by zeroing the memory in parallel
>> when struct pages are zeroed.
> 
> First of all this should be probably merged with the previous patch. The
> I think vmemmap_alloc_block would be better to split up into
> __vmemmap_alloc_block which doesn't zero and vmemmap_alloc_block which
> does zero which would reduce the memset callsites and it would make it
> slightly more robust interface.

Ok, I will add: vmemmap_alloc_block_zero() call, and merge this and the 
previous patches together.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
