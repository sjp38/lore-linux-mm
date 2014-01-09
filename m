Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 764486B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 05:06:40 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id u14so1041053bkz.25
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 02:06:39 -0800 (PST)
Received: from mail-bk0-x229.google.com (mail-bk0-x229.google.com [2a00:1450:4008:c01::229])
        by mx.google.com with ESMTPS id ch10si1766387bkc.61.2014.01.09.02.06.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 02:06:39 -0800 (PST)
Received: by mail-bk0-f41.google.com with SMTP id v15so1057316bkz.14
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 02:06:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140108212636.GC15313@quack.suse.cz>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
	<20140107122301.GC16640@quack.suse.cz>
	<CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
	<20140108111640.GD8256@quack.suse.cz>
	<CAK25hWN_tWu=HrOzs-eu6UFbp-6G=3pZJs+svcBu0hBxErm02g@mail.gmail.com>
	<20140108212636.GC15313@quack.suse.cz>
Date: Thu, 9 Jan 2014 15:36:38 +0530
Message-ID: <CAK25hWO+NjUNYTdD_SFLetchWT+XBq49mn0-hVyiOnmC9vJSDg@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

>> As already mentioned that the issue that we were facing was that "too
>> many copyups were made on the  read-write file system".
>   But my question is: In which cases specifically do you want to avoid
> copyups as compared to e.g. Overlayfs?
>
    To be honest I do not the answer. I had senior kernel developers
from Cern who guided me when working on this driver. I need to consult
them in order to answer you correctly. I would try to be bring them in
this thread to get you the right answer.

Regards,
Saket Sinha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
