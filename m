Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 48A0182905
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 16:01:02 -0400 (EDT)
Received: by pabrd3 with SMTP id rd3so13989017pab.6
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:01:02 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id oz10si9199631pdb.15.2015.03.11.13.01.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 13:01:01 -0700 (PDT)
Received: by pdjp10 with SMTP id p10so13715742pdj.10
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:01:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150311.144443.1290707334236248572.davem@davemloft.net>
References: <55004595.7020304@oracle.com>
	<20150311.132052.205877953171712952.davem@davemloft.net>
	<55007A9B.4010608@oracle.com>
	<20150311.144443.1290707334236248572.davem@davemloft.net>
Date: Wed, 11 Mar 2015 23:01:00 +0300
Message-ID: <CAPAsAGwuCzzDCgiNd=LrHA_W1Nj5TJu3Qym9tR3jnGdT45HQuw@mail.gmail.com>
Subject: Re: [PATCH] mm: kill kmemcheck
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Sasha Levin <sasha.levin@oracle.com>, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-arch@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-crypto@vger.kernel.org

2015-03-11 21:44 GMT+03:00 David Miller <davem@davemloft.net>:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Wed, 11 Mar 2015 13:25:47 -0400
>
>> You're probably wondering why there are changes to SPARC in that patchset? :)
>
> Libsanitizer doesn't even build have the time on sparc, the release
> manager has to hand patch it into building again every major release
> because of the way ASAN development is done out of tree and local
> commits to the gcc tree are basically written over during the
> next merge.
>

Libsanitizer is userspace lib it's for userspace ASan, KASan doesn't use it.
We have our own 'libsanitzer' in kernel.

> So I'm a little bit bitter about this, as you can see. :)
>


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
