Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6FD2C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:00:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 733112173E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:00:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 733112173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 315396B0003; Wed, 22 May 2019 17:00:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4E76B0006; Wed, 22 May 2019 17:00:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18D456B0007; Wed, 22 May 2019 17:00:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5D6F6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 17:00:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1so5405446edi.20
        for <linux-mm@kvack.org>; Wed, 22 May 2019 14:00:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G8OWB/V45Wd198bLA0RLdqVoYpQKpd6s9powucOZvvY=;
        b=o510nZ+pxBThof6PvtAyTbNxWCPaWIEBBjkj/axDsORi8OENx4lD83D2ENTJAADzGV
         lfdYLpGub/ZR6lbjNqxbr87YRJogaAZd1FJbWlfgmM6GuELK5YrxRlwCNqNEF+HT5saD
         77OjzL0SGIdh68iV+F5vLe3Yx656xNmUN0JkwhwA3P+B6muYO9V6kcxqARkE7FSiDX3V
         HtqpkPkZ8Yj6aoj4/o+w1b670C++4c50p0NfPG2KzpPhoW5JYgl5U2SV+83LICAbEnZa
         ljc3wy4azMywXi2KjsiMLG0zGCYbQ0r1WrH8d9EKU9N7n80JaQONefHg05SsAw4/0jDf
         quig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Gm-Message-State: APjAAAW1zu+hlfGa33AE0aqNJL1phAMrP00XPzUjKImeOzWHF7vrQLRi
	rMnZ1i12aRIaE8b72yDnNgNT5gYJMnT78kzXUWM2AIuA2i9WE/AtsUVUfl5HDF7m/aXL+9kIvZd
	rMhzZKvCj7f46/uyPc2S9MvHvB4DCUs2ZjjGlKDIHQICEw1BylDsd/4zxTAcSiqoJVQ==
X-Received: by 2002:a50:fc97:: with SMTP id f23mr91544744edq.104.1558558857444;
        Wed, 22 May 2019 14:00:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyw0wB98hujEeXutsG3tyffQJTAtLixX+b4gB/C0UR4OKEjdCHz9Ja8f8cgfWQDgRjLNbwO
X-Received: by 2002:a50:fc97:: with SMTP id f23mr91544652edq.104.1558558856708;
        Wed, 22 May 2019 14:00:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558558856; cv=none;
        d=google.com; s=arc-20160816;
        b=SW/Pii37gYKymagt8g6UhkHD0EmGYb2yFkfwLndMOwtW9qezUXPy9SUKkgI4+E9XZS
         utCZQp6bKUiXTGiPu2r48118zp/ZAZPMJPndH0qolzLGH4nRRfkMfNDfvlHbIDQcodRF
         2GzIvPP5t/g5qNJ8isVULWU1/sq0D9SusoZ6H1D0E8isQ+zjrfnt1hmpmBe6t11dqWGE
         pjixRB9JUlvU9wh5wDnVXvaIiJtPbcyFBwYGRsZsm1TjoopjDTxsAZpxYm1ATYQcJoXO
         QWAKBaaGty2Gu/I+kCs4aOE7lZgA/YY4GV4dnqu2wri2W8BgnRpLEaWKObazRGOtPkaj
         9Dng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=G8OWB/V45Wd198bLA0RLdqVoYpQKpd6s9powucOZvvY=;
        b=cFI1TItKk7yRHPIB01XrITPV5CLGua13fEFPpTMPi0Vq6Q6htjynoXbIVIpTlHoaXj
         0xUFUZUwJaTxTcEPEadC0ogSDcJ2wEcwWxd2LfgwPoZM1pvI4hR81UGJQ7w2yt5REUO9
         ZnAtdXpmjnAhtMO7KXLQkTZAbiIjDt5HuGclOLpIXxxXZ6R3HhsGXNOTK/jn4tjqNCtG
         Ro6GzFt+aitr+PEYc/j+STSjiQ4u4ZdIBe0JQWVgIWnzMBnHHViHOwbWiGJLsN3+x1jt
         gevraNTiAdvNN2cmvccGAZfelE4RY5RgZLxVg1ZADzG8f4ERh/3IrlVJ/rfVIPxWFSJT
         eaBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u8si6776559ejr.211.2019.05.22.14.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 14:00:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E4870AD78;
	Wed, 22 May 2019 21:00:55 +0000 (UTC)
Message-ID: <1558558075.2470.2.camel@suse.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
From: Oliver Neukum <oneukum@suse.com>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Jaewon Kim <jaewon31.kim@gmail.com>, Christoph Hellwig
 <hch@infradead.org>,  linux-mm@kvack.org, gregkh@linuxfoundation.org,
 Jaewon Kim <jaewon31.kim@samsung.com>, m.szyprowski@samsung.com,
 ytk.lee@samsung.com,  linux-kernel@vger.kernel.org,
 linux-usb@vger.kernel.org
Date: Wed, 22 May 2019 22:47:55 +0200
In-Reply-To: <Pine.LNX.4.44L0.1905221055190.1410-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.1905221055190.1410-100000@iolanthe.rowland.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mi, 2019-05-22 at 10:56 -0400, Alan Stern wrote:
> On Wed, 22 May 2019, Oliver Neukum wrote:
> 
> > I agree with the problem, but I fail to see why this issue would be
> > specific to USB. Shouldn't this be done in the device core layer?
> 
> Only for drivers that are on the block-device writeback path.  The 
> device core doesn't know which drivers these are.

Neither does USB know. It is very hard to predict or even tell which
devices are block device drivers. I think we must assume that
any device may be affected.

	Regards
		Oliver

