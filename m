Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CBFD38296B
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 16:48:10 -0400 (EDT)
Received: by padfb1 with SMTP id fb1so14300039pad.7
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:48:10 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ej8si5606691pdb.104.2015.03.11.13.48.09
        for <linux-mm@kvack.org>;
        Wed, 11 Mar 2015 13:48:09 -0700 (PDT)
Date: Wed, 11 Mar 2015 16:48:07 -0400 (EDT)
Message-Id: <20150311.164807.1389597491151339402.davem@davemloft.net>
Subject: Re: [PATCH] mm: kill kmemcheck
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAPAsAGwuCzzDCgiNd=LrHA_W1Nj5TJu3Qym9tR3jnGdT45HQuw@mail.gmail.com>
References: <55007A9B.4010608@oracle.com>
	<20150311.144443.1290707334236248572.davem@davemloft.net>
	<CAPAsAGwuCzzDCgiNd=LrHA_W1Nj5TJu3Qym9tR3jnGdT45HQuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ryabinin.a.a@gmail.com
Cc: sasha.levin@oracle.com, rostedt@goodmis.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Date: Wed, 11 Mar 2015 23:01:00 +0300

> 2015-03-11 21:44 GMT+03:00 David Miller <davem@davemloft.net>:
>> From: Sasha Levin <sasha.levin@oracle.com>
>> Date: Wed, 11 Mar 2015 13:25:47 -0400
>>
>>> You're probably wondering why there are changes to SPARC in that patchset? :)
>>
>> Libsanitizer doesn't even build have the time on sparc, the release
>> manager has to hand patch it into building again every major release
>> because of the way ASAN development is done out of tree and local
>> commits to the gcc tree are basically written over during the
>> next merge.
>>
> 
> Libsanitizer is userspace lib it's for userspace ASan, KASan doesn't use it.
> We have our own 'libsanitzer' in kernel.

I was speaking about ASAN development in general, of which the
libsanitizer issue is a byproduct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
