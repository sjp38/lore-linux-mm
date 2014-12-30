Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 04F506B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 02:16:38 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so19167510pad.9
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 23:16:37 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id fv5si56333849pbb.173.2014.12.29.23.16.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 29 Dec 2014 23:16:36 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHD00G29WEBSB30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 30 Dec 2014 07:20:35 +0000 (GMT)
Message-id: <54A25135.5030103@samsung.com>
Date: Tue, 30 Dec 2014 08:16:05 +0100
From: Andrzej Hajda <a.hajda@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC PATCH 0/4] kstrdup optimization
References: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
 <87egrhws89.fsf@tassilo.jf.intel.com>
In-reply-to: <87egrhws89.fsf@tassilo.jf.intel.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

On 12/30/2014 07:45 AM, Andi Kleen wrote:
> Andrzej Hajda <a.hajda@samsung.com> writes:
>
>> kstrdup if often used to duplicate strings where neither source neither
>> destination will be ever modified. In such case we can just reuse the source
>> instead of duplicating it. The problem is that we must be sure that
>> the source is non-modifiable and its life-time is long enough.
> What happens if someone is to kfree() these strings?
>
> -Andi
>
kstrdup_const must be accompanied by kfree_const, I did not mention it
in cover letter
but it is described in the 1st patch commit message.
Simpler alternative (but I am not sure if better) would be to add
similar check
(ie. if pointer is in .rodata) to kfree itself.

Regards
Andrzej

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
