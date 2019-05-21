Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A88E9C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 13:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 748F12173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 13:24:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 748F12173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03E306B0003; Tue, 21 May 2019 09:24:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F30C76B0006; Tue, 21 May 2019 09:24:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E464B6B000A; Tue, 21 May 2019 09:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 975836B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 09:24:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b22so30784708edw.0
        for <linux-mm@kvack.org>; Tue, 21 May 2019 06:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ejscCpBqbOLVOlM5y870lFaJVE4bE9aesagyHKMmUg0=;
        b=WNAvu3SRxvrcD7uytKWlVuPOjcq1egaGiXwovHb6PcH5aKk63zv3L/lfoRtLglMs5M
         WPLRfmQ2al8s2ZXHk7hGzPKH4SYu0uFV9P3Ut10aGohQ3epnSO174Kue9fPsbCJZQ58p
         XPLFgV6z8s+EmSJlaFGEo86Lj3MvqsVRLfpSUTzhv9O7rI4u//pNzJMXAJu3TiVC5b8y
         Lnd409agkaQWbeT40OAouGBiBtyCZtiaF3BsK3W/YyNAYTsoW+06BuWEAnjySRKXr1CL
         xYwP/5xh3zmekQMWOqqXQHLK05OW93myHBO5hFT6xvUTBxcBPpf+M79vZvZBT2QH/I6O
         lV8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Gm-Message-State: APjAAAV4x0W+oQdVKWGvzgthkTnyBaspmrCav4w3PHG3VN/D+YEig9s/
	eKEJGs+qMc86CPAq7HASomd+TZHv1/YoSw1Ys6BsArT8dKbYGaO9q0aPUbjU7Pr4Nf3RfIRq0Sd
	C6CQgR+2mRyoCLl+AbuVxb3bXWeY4qrMGqaaCv40263KP1Z5IsBCQ7kpp0Qk3m5vhmg==
X-Received: by 2002:a17:906:2db2:: with SMTP id g18mr57296010eji.79.1558445072168;
        Tue, 21 May 2019 06:24:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2awQSay7hdsq3DG1GHV5g3SWFksJtEf5z4ebdCfQDWNB3hzu3QPbUxpSDy0Ufh6opdSRr
X-Received: by 2002:a17:906:2db2:: with SMTP id g18mr57295924eji.79.1558445071063;
        Tue, 21 May 2019 06:24:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558445071; cv=none;
        d=google.com; s=arc-20160816;
        b=pr3tblV2eCqUytBbmw8O8WDegUl1TuIHGkyo1xggJu9icE1tMwVgUdWlmEX6mbZsnd
         dLcrcJIkWYeV2tVulN+jKRtqngzHy9qsx7QTpyo0Kgw4q1zMFuUiUHnxw3ni1ZuX8K48
         LTo2YnOHpf1mutPxnOBmufApl/Y/L1FtiYq3NMrAt4d7faCb0VWrRj2DjEd5gCEYboTy
         gDXn1ocRedU2WF/xNKLp8UcYDyvrzVY/HK/YSR2tozObu4a0JMaKofMxsyxDv+PR7JVg
         nA1Rv/JpoYdCftc+7hYt4qK0JIBbb/p8qGIU77UErMlW1OMecPzvOzZfnxFHFpXRIhhY
         e+Dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=ejscCpBqbOLVOlM5y870lFaJVE4bE9aesagyHKMmUg0=;
        b=rGE0zQn27T23tNFm+7ruUf2Ct6DtCsv21P01HhrnTX6MCtsMdPWIHIf7CfbgWcsIJQ
         o3tan9UblUDpCh5VkgHJZkP26XXTnuX6PWRjt8852qTNhAzU6xXe5oRAf2YciUVGIy3a
         9/wAN9m8WYka8dOnujrM4KRLsyAwLtxLlmwqnr2/qzJzmf73njvyaH+ntvyHtRS5ToZo
         O1dIzmiGkVRrtuZqylmS5B1SnTtoQ1dWR1qAIbRcIoYoaJWq3CU2aUbW1D3GJ0GlUwls
         /crStMXjhr5jI8JSmk1eiaF4n++boFiBuvTZOXrNu5QqaeJpCtrm6rB/bfuLdwVzfDaM
         vGbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e52si2845558edb.265.2019.05.21.06.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 06:24:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3EA72ADCB;
	Tue, 21 May 2019 13:24:30 +0000 (UTC)
Message-ID: <1558444291.12672.23.camel@suse.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
From: Oliver Neukum <oneukum@suse.com>
To: Alan Stern <stern@rowland.harvard.edu>, Christoph Hellwig
	 <hch@infradead.org>
Cc: Jaewon Kim <jaewon31.kim@gmail.com>, linux-mm@kvack.org, 
 gregkh@linuxfoundation.org, Jaewon Kim <jaewon31.kim@samsung.com>, 
 m.szyprowski@samsung.com, ytk.lee@samsung.com,
 linux-kernel@vger.kernel.org,  linux-usb@vger.kernel.org
Date: Tue, 21 May 2019 15:11:31 +0200
In-Reply-To: <Pine.LNX.4.44L0.1905201011490.1498-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.1905201011490.1498-100000@iolanthe.rowland.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mo, 2019-05-20 at 10:16 -0400, Alan Stern wrote:
> On Mon, 20 May 2019, Christoph Hellwig wrote:
> 
> > GFP_KERNEL if you can block, GFP_ATOMIC if you can't for a good reason,
> > that is the allocation is from irq context or under a spinlock.  If you
> > think you have a case where you think you don't want to block, but it
> > is not because of the above reasons we need to have a chat about the
> > details.
> 
> What if the allocation requires the kernel to swap some old pages out 
> to the backing store, but the backing store is on the device that the 
> driver is managing?  The swap can't take place until the current I/O 
> operation is complete (assuming the driver can handle only one I/O 
> operation at a time), and the current operation can't complete until 
> the old pages are swapped out.  Result: deadlock.
> 
> Isn't that the whole reason for using GFP_NOIO in the first place?

Hi,

lookig at this it seems to me that we are in danger of a deadlock

- during reset - devices cannot do IO while being reset
	covered by the USB layer in usb_reset_device
- resume & restore - devices cannot do IO while suspended
	covered by driver core in rpm_callback
- disconnect - a disconnected device cannot do IO
	is this a theoretical case or should I do something to
	the driver core?

How about changing configurations on USB?

	Regards
		Oliver

