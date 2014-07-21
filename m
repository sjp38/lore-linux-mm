Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B257C6B0038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:48:33 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so10209590pac.31
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 09:48:33 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id pm3si14781778pbb.64.2014.07.21.09.48.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 09:48:32 -0700 (PDT)
Message-ID: <53CD443A.6050804@zytor.com>
Date: Mon, 21 Jul 2014 09:47:54 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>	 <53C58A69.3070207@zytor.com> <1405459404.28702.17.camel@misato.fc.hp.com>	 <03d059f5-b564-4530-9184-f91ca9d5c016@email.android.com>	 <1405546127.28702.85.camel@misato.fc.hp.com> <1405960298.30151.10.camel@misato.fc.hp.com>
In-Reply-To: <1405960298.30151.10.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On 07/21/2014 09:31 AM, Toshi Kani wrote:
> Do you have any comments / suggestions for this approach?

Approach to what, specifically?

Keep in mind the PAT bit is different for large pages.  This needs to be
dealt with.  I would also like a systematic way to deal with the fact
that Xen (sigh) is stuck with a separate mapping system.

I guess Linux could adopt the Xen mappings if that makes it easier, as
long as that doesn't have a negative impact on native hardware -- we can
possibly deal with some older chips not being optimal.  However, my
thinking has been to have a "reverse PAT" table in memory of memory
types to encodings, both for regular and large pages.

	-hpa



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
