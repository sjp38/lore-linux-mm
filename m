Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60F4DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:37:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 262B8218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:37:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 262B8218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=free.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB94D8E00FF; Mon, 11 Feb 2019 11:37:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8F838E00F6; Mon, 11 Feb 2019 11:37:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 957A88E00FF; Mon, 11 Feb 2019 11:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5E28E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:37:07 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id o16so7131431wmh.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9iFP07fxHdk5sbtZBDQ5tYevIqcQ8CHmZFXd1v8eDFc=;
        b=DwC84FSW8r+94arHShUoeXc2XGMLPff7rTqywB2G00hCbCdzChL8rDt44hl1xgNnyF
         IvdeiOcDM/MGZq+WWzIOxIBaLcShvgobPlEb5vHZvhz2IipE7N3eW8ftRdpr2MG2a2cu
         HYRbFOWt83tzo9x+1QwCSGlQjGzds377zAmntUSblOsrF+FH5H8EYVkfs0f+xixxX4ND
         O7/6Y7OyHa+scikGJsiIKuHtj4RMpbTPwgbUyiQ0t0SDmGWt7PIROT1UEAANE8JHdwPc
         nO+EZhevlQIAYi5+s3yj5sgU5Y7qJJPKTQ54SA7uBe5dF5G/4I5JtuZL9TmTKWFy8rRr
         5l8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::12 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
X-Gm-Message-State: AHQUAuYpdvMYHN0osr5lrxqWtG4IsPGev6hZfgkNlGUNXea22ahqq3nw
	0Fwy/ZdC5OUdSZ9S43rr2bPzaJsdC5LaqQQQoKLBx0MboJbL4STccPzC8M3TlU1kAer8eDCUUqh
	PKaUFkjEDyHomVK/axBUjxngDbWyDq6MEQJ7sgE7vY8SHBd1c6TUIvEw3MFt6XkUwFQ==
X-Received: by 2002:adf:a147:: with SMTP id r7mr3005908wrr.5.1549903026796;
        Mon, 11 Feb 2019 08:37:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYc6q2h5uk162i25ehl4g5hEc5QQwD0hguf5soWFInOYgYpkdGwb7tx0ifcAslUUxKx6o7a
X-Received: by 2002:adf:a147:: with SMTP id r7mr3005852wrr.5.1549903025788;
        Mon, 11 Feb 2019 08:37:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549903025; cv=none;
        d=google.com; s=arc-20160816;
        b=I2NUv7tGe+XzUM2xsgnUmH+3VtNn2J8rscGFHZu1/xR5MZz/srC1fpnml8dnMG4JTJ
         q3dPl0q89J+vrb8F8rdAT0IcCMAkMIIg7JS2hagufZfX4nZ45IzmFB6uEB51i7qEv1vn
         Iq8nJZZbbMbT7X5Ux3pz6BpKZSBzZp2NWqXtPHyrfqnFCC2pYSdfp3FhIhnRGeaR4X37
         c/D9MzgICMvZ583xCiIrkIzI+vjpPajjQJrxmbuvEh8Hr9CEItUK5nqI3Xlx53IwqIik
         9wYSRNEnbQbYyDsadUO82yF8+ySuo8Pni5MJqmcS4AHWMLLZQUT3iPwEumLXkAEv7vzz
         T2WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9iFP07fxHdk5sbtZBDQ5tYevIqcQ8CHmZFXd1v8eDFc=;
        b=P/jdI/yyh5WxUlLcItpf0wCx6/5rSVWVdeVO4rVD99bVRYQc3FixvK2eGRZ1HG36G3
         w2qM+Sepm6yt8ksugOBNeaCB+IgKx8p6KTeS48MWNqOnhmkN7+wrLhr3diAyQJeYyHIi
         KCrMB1T9lB3RTLtv+4FAj18Dulc4yF9LraTn7xmlq73BsMf58uBSIk+HPmUIyvLsd0t6
         JJXrA0RrxEShX28bisfUJ2m/oO4k1kBqshv1ecq988FkXrawZivjiOS/Kor50XjhCbLK
         Vgp3y7pY7eHnoD8ONdPHb2YyRzYsIPgqxDiT0M6FOtiUh5T9AemxQcnxQfQvRvDyxi3U
         ysQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::12 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from smtp3-g21.free.fr (smtp3-g21.free.fr. [2a01:e0c:1:1599::12])
        by mx.google.com with ESMTPS id 187si3020087wmc.138.2019.02.11.08.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:37:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::12 as permitted sender) client-ip=2a01:e0c:1:1599::12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::12 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from [192.168.108.68] (unknown [213.36.7.13])
	(Authenticated sender: marc.w.gonzalez)
	by smtp3-g21.free.fr (Postfix) with ESMTPSA id 707ED13F8C1;
	Mon, 11 Feb 2019 17:36:13 +0100 (CET)
Subject: Re: dd hangs when reading large partitions
To: Bart Van Assche <bvanassche@acm.org>, linux-mm <linux-mm@kvack.org>,
 linux-block <linux-block@vger.kernel.org>
Cc: Jianchao Wang <jianchao.w.wang@oracle.com>,
 Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
 fsdevel <linux-fsdevel@vger.kernel.org>, SCSI <linux-scsi@vger.kernel.org>,
 Jeffrey Hugo <jhugo@codeaurora.org>, Evan Green <evgreen@chromium.org>,
 Matthias Kaehlcke <mka@chromium.org>,
 Douglas Anderson <dianders@chromium.org>, Stephen Boyd
 <swboyd@chromium.org>, Tomas Winkler <tomas.winkler@intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Bart Van Assche <bart.vanassche@wdc.com>,
 Martin Petersen <martin.petersen@oracle.com>,
 Bjorn Andersson <bjorn.andersson@linaro.org>, Ming Lei
 <ming.lei@redhat.com>, Omar Sandoval <osandov@fb.com>,
 Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>, James Bottomley <jejb@linux.ibm.com>
References: <f792574c-e083-b218-13b4-c89be6566015@free.fr>
 <398a6e83-d482-6e72-5806-6d5bbe8bfdd9@oracle.com>
 <ef734b94-e72b-771f-350b-08d8054a58f3@kernel.dk>
 <20190119095601.GA7440@infradead.org>
 <07b2df5d-e1fe-9523-7c11-f3058a966f8a@free.fr>
 <985b340c-623f-6df2-66bd-d9f4003189ea@free.fr>
 <b3910158-83d6-21fe-1606-33e88912404a@oracle.com>
 <d082bdee-62e5-d470-b63b-196c0fe3b9fb@free.fr>
 <5132e41b-cb1a-5b81-4a72-37d0f9ea4bb9@oracle.com>
 <7bd8b010-bf0c-ad64-f927-2d2187a18d0b@free.fr>
 <0cfe1ed2-41e1-66a4-8d98-ebc0d9645d21@free.fr>
 <d91e8342-4672-d51d-1bde-74e910e5a959@free.fr>
 <27165898-88c3-ab42-c6c9-dd52bf0a41c8@free.fr>
 <66419195-594c-aa83-c19d-f091ad3b296d@free.fr>
 <1549640986.34241.78.camel@acm.org>
From: Marc Gonzalez <marc.w.gonzalez@free.fr>
Message-ID: <690af800-1cd2-3e68-94d9-bc4825790837@free.fr>
Date: Mon, 11 Feb 2019 17:36:13 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1549640986.34241.78.camel@acm.org>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/02/2019 16:49, Bart Van Assche wrote:

> Does this problem only occur with block devices backed by the UFS driver
> or does this problem also occur with other block drivers?

Yes, same issue with a USB3 mass storage device:

usb 2-1: new SuperSpeed Gen 1 USB device number 2 using xhci-hcd
usb 2-1: New USB device found, idVendor=05dc, idProduct=a838, bcdDevice=11.00
usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 2-1: Product: USB Flash Drive
usb 2-1: Manufacturer: Lexar
usb 2-1: SerialNumber: AAYW2W7I13BAR0JC
usb-storage 2-1:1.0: USB Mass Storage device detected
scsi host0: usb-storage 2-1:1.0
scsi 0:0:0:0: Direct-Access     Lexar    USB Flash Drive  1100 PQ: 0 ANSI: 6
sd 0:0:0:0: [sda] 62517248 512-byte logical blocks: (32.0 GB/29.8 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 43 00 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1
sd 0:0:0:0: [sda] Attached SCSI removable disk

# dd if=/dev/sda of=/dev/null bs=1M status=progress
3879731200 bytes (3.9 GB, 3.6 GiB) copied, 56.0097 s, 69.3 MB/s

This definitively rules out drivers/scsi/ufs
(Dropping UFS people)

So the problem could be in SCSI glue, or block, or mm?

How can I pinpoint the bug?

Problem statement and logs:
https://lore.kernel.org/linux-block/66419195-594c-aa83-c19d-f091ad3b296d@free.fr/

Regards.

