Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE3BC6B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 13:20:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i124so32295635wmf.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:20:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s55si3715939edb.425.2017.10.10.10.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 10:20:00 -0700 (PDT)
Subject: Re: [PATCH v11 0/9] complete deferred page initialization
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171010141547.zpdptsccsblyw634@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <bd333387-fefc-c48a-2258-1d8c36f2db41@oracle.com>
Date: Tue, 10 Oct 2017 13:19:19 -0400
MIME-Version: 1.0
In-Reply-To: <20171010141547.zpdptsccsblyw634@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

I wanted to thank you Michal for spending time and doing the in-depth 
reviews of every incremental change. Overall the series is in much 
better shape now because of your feedback.

Pavel

On 10/10/2017 10:15 AM, Michal Hocko wrote:
> Btw. thanks for your persistance and willingness to go over all the
> suggestions which might not have been consistent btween different
> versions. I believe this is a general improvement in the early
> initialization code. We do not rely on an implicit zeroing which just
> happens to work by a chance. The perfomance improvements are a bonus on
> top.
> 
> Thanks, good work!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
