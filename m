Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 09EAA900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:20:58 -0400 (EDT)
Received: by pdbfp1 with SMTP id fp1so12725069pdb.7
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 10:20:57 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id r7si8253477pdp.128.2015.03.11.10.20.55
        for <linux-mm@kvack.org>;
        Wed, 11 Mar 2015 10:20:56 -0700 (PDT)
Date: Wed, 11 Mar 2015 13:20:52 -0400 (EDT)
Message-Id: <20150311.132052.205877953171712952.davem@davemloft.net>
Subject: Re: [PATCH] mm: kill kmemcheck
From: David Miller <davem@davemloft.net>
In-Reply-To: <55004595.7020304@oracle.com>
References: <55003666.3020100@oracle.com>
	<20150311084034.04ce6801@grimm.local.home>
	<55004595.7020304@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Wed, 11 Mar 2015 09:39:33 -0400

> On 03/11/2015 08:40 AM, Steven Rostedt wrote:
>> On Wed, 11 Mar 2015 08:34:46 -0400
>> Sasha Levin <sasha.levin@oracle.com> wrote:
>> 
>>> > Fair enough. We knew there are existing kmemcheck users, but KASan should be
>>> > superior both in performance and the scope of bugs it finds. It also shouldn't
>>> > impose new limitations beyond requiring gcc 4.9.2+.
>>> >
>> Ouch! OK, then I can't use it. I'm currently compiling with gcc 4.6.3.
>> 
>> It will be a while before I upgrade my build farm to something newer.
> 
> Are you actually compiling new kernels with 4.6.3, or are you using older
> kernels as well?
> 
> There's no real hurry to kill kmemcheck right now, but we do want to stop
> supporting that in favour of KASan.

Is the spectrum of CPU's supported by this GCC feature equal to all of the
CPU's supported by the kernel right now?

If not, removing kmemcheck will always be a regression for someone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
