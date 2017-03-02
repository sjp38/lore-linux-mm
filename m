Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2846B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 14:15:52 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u62so91644273pfk.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 11:15:52 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s5si8244391plj.108.2017.03.02.11.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 11:15:51 -0800 (PST)
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
 <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
 <87h93dhmir.fsf@firstfloor.org>
 <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
 <20170301151910.GH26852@two.firstfloor.org>
 <6a26815d-0ec2-7922-7202-b1e17d58aa00@oracle.com>
 <20170301173136.GI26852@two.firstfloor.org>
 <1e7db21b-808d-1f47-e78c-7d55c543ae39@oracle.com>
 <20170301231025.GJ26852@two.firstfloor.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <219d73df-3620-b7ed-7b3d-b1612435a9ff@oracle.com>
Date: Thu, 2 Mar 2017 14:15:34 -0500
MIME-Version: 1.0
In-Reply-To: <20170301231025.GJ26852@two.firstfloor.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi Andi,

>
> I think a upper size (with user override which already exists) is fine,
> but if you really don't want to do it then scale the factor down
> very aggressively for larger sizes, so that we don't end up with more
> than a few tens of MB.
>

I have scaled it, I do not think setting a default upper limit is a 
future proof strategy.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
