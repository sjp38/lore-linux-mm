Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E86036B0038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 16:23:34 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so10328001pad.21
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:23:34 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id c2si7213843pdp.191.2014.07.21.13.23.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 13:23:33 -0700 (PDT)
Message-ID: <53CD7694.9010008@zytor.com>
Date: Mon, 21 Jul 2014 13:22:44 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com> <53C58A69.3070207@zytor.com> <1405459404.28702.17.camel@misato.fc.hp.com> <03d059f5-b564-4530-9184-f91ca9d5c016@email.android.com> <1405546127.28702.85.camel@misato.fc.hp.com> <1405960298.30151.10.camel@misato.fc.hp.com> <53CD443A.6050804@zytor.com> <1405962993.30151.35.camel@misato.fc.hp.com> <53CD4EB2.5020709@zytor.com> <20140721183331.GB13420@laptop.dumpdata.com>
In-Reply-To: <20140721183331.GB13420@laptop.dumpdata.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Toshi Kani <toshi.kani@hp.com>, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On 07/21/2014 11:33 AM, Konrad Rzeszutek Wilk wrote:
>>
>> First of all, paravirt functions are the root of all evil, and we want
> 
> Here I was thinking to actually put an entry in the MAINTAINERS
> file for me to become the owner of it - as the folks listed there
> are busy with other things.
> 
> The Maintainer of 'All Evil' has an interesting ring to it :-)
> 

Then you can legitimately title yourself Lord of All Evil.  :)

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
