Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA576B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 15:21:33 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so398448bkb.12
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 12:21:32 -0800 (PST)
Received: from mail-bk0-x229.google.com (mail-bk0-x229.google.com [2a00:1450:4008:c01::229])
        by mx.google.com with ESMTPS id qz1si24504143bkb.69.2014.01.07.12.21.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 12:21:32 -0800 (PST)
Received: by mail-bk0-f41.google.com with SMTP id v15so403334bkz.28
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 12:21:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <25625.1389113579@jrobl>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
	<25625.1389113579@jrobl>
Date: Wed, 8 Jan 2014 01:51:32 +0530
Message-ID: <CAK25hWNeZnxkRYLpp3acRzxDVGNrmxY2g0ZkivhdrNoK+hMdCQ@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

> Just out of curious, I remember a guy in CERN had posted a message to
> aufs-users ML.
> http://www.mail-archive.com/aufs-users@lists.sourceforge.net/msg04020.html
>
> Are you co-working with him?
Yes. Jacob Bloomer was one of my mentors during this initiative.

 >> CERN totally stopped using aufs?
You can see we decided to write our own. The details about our effort
can be found here at my github page
https://github.com/disdi/hepunion

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
