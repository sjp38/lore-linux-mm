Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCF8F6B0260
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:02:09 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r6so2981765itr.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:02:09 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n82si2829307ioe.108.2017.12.19.12.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 12:02:08 -0800 (PST)
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface for
 freeing rcu structures
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <alpine.DEB.2.20.1712191332090.7876@nuc-kabylake>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <b38f36d7-be4f-8cc4-208e-f0778077a063@oracle.com>
Date: Tue, 19 Dec 2017 12:02:03 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712191332090.7876@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org



On 12/19/2017 11:33 AM, Christopher Lameter wrote:
> On Tue, 19 Dec 2017, rao.shoaib@oracle.com wrote:
>
>> This patch updates kfree_rcu to use new bulk memory free functions as they
>> are more efficient. It also moves kfree_call_rcu() out of rcu related code to
>> mm/slab_common.c
> It would be great to have separate patches so that we can review it
> properly:
>
> 1. Move the code into slab_common.c
> 2. The actual code changes to the kfree rcu mechanism
> 3. The whitespace changes
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
I can certainly break down the patch and submit smaller patches as you 
have suggested.

BTW -- This is my first ever patch to Linux, so I am still learning the 
etiquette.

Shoaib

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
