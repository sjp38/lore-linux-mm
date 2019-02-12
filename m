Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67F4CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:27:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3113820863
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:27:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3113820863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=free.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA60F8E0005; Tue, 12 Feb 2019 10:27:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7D5A8E0001; Tue, 12 Feb 2019 10:27:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B93758E0005; Tue, 12 Feb 2019 10:27:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 649DF8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:27:03 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t133so1138323wmg.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:27:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=dcMm0kE5qxkntCrevwhlMtNR5mhhW1J4gCjlyHdLZrQ=;
        b=AAcRGHhq9s/xhjfclSDLMyAc8DGlq6nMPIyIB+8id82MyynfJGm9JfEBTkkJvXye/Y
         T2TWr300SnTPM3hGBBYrItGlWBsKq0WiBKo0ixapEnlLZP5OLNMErXL3pnD0tlf98Qh4
         OiGjKxkXrb7QpNJ3JdkRjQ9yzWvl4al4RtsDz7ACs5VsROHFRWEF3BEqvXJvEwXPkn5R
         TL5Xwo09gP7Qcrr+jjNHJI7FwWBHLXXXt4L0aOgZ79rPIMM0UFwHuniWCA90dp57z9Ij
         pCP1zMFOcgbblGNqL3zjTe6qeA8fJU1Nk7EHKy/ap/KRcx1Q80B67ClHI43d9yM3SSb4
         p7bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
X-Gm-Message-State: AHQUAuYMA+4G5k/tNQGouOBjbcUMTwOysmuhZ0fnC6vqsyMBlkRzvWKF
	ISw3ds/z5Gztbe48E9iMdiaGNILiCGMd76+lOZhoOYXdcOakd/6tFtZ323HTKK9CbVwaGYu+F1N
	vxXhJDxo9SChpDmZL/xFjIOGUd084UACExDcg+oR+yVeY93i3usYcWt7N8BPfHVgh6Q==
X-Received: by 2002:adf:afce:: with SMTP id y14mr2826480wrd.219.1549985222993;
        Tue, 12 Feb 2019 07:27:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IakapcG66EsKDRparj09MCQhfGsyDo2BSpzUli3ZtoMLgZfCq0rMzbXkCjxsut2dvVDnb7a
X-Received: by 2002:adf:afce:: with SMTP id y14mr2826422wrd.219.1549985222212;
        Tue, 12 Feb 2019 07:27:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549985222; cv=none;
        d=google.com; s=arc-20160816;
        b=n31FQBcAWy3BNQAsMZtP121H4jLShbeMAUXGtfOaXNCRyooVd30l9YYSQkTt+yE6oM
         cusWFEfVqQ4XnKwIbw3WrCei6siE0UgE9SQdvP2saHkFvYPNyc0cfKEDVkMuCa1vQelM
         XCySYiyb0uoMTP2v5wKMkdbZDZbH/N9Z1ZgW12fUR+EAwThdLfGc8r93ds7yq99hkQSx
         lnRJKT/G4mZrYqpUtviEkXNlE5SGj0Puqvc7Jq4Sikp+8Iuh3qAzC3rJZmcnJrhvaKtD
         eBWKNE4Pm2X4kH95R3Ia/k3A7SlOnckPbgf7N2MclwNo/Cvaz23WHmuScYsY9GsMkZfz
         e7kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=dcMm0kE5qxkntCrevwhlMtNR5mhhW1J4gCjlyHdLZrQ=;
        b=iGGKpgPl+wO50rWe1K3qeLEoypU/U2j7VylOdsz8/tZoatRth/ROHl478+Mq2jiFNI
         gEqIwpLI0++2XWyM83w7bv0Hlqbj65Iu/Xq+9dgz3FW/xTTbUcwGxyqqNTDG/LxdIEjT
         fyWJQ/rZdbDic7EqtIofUs02A9BwlGTnjl2STVYX0SSRWJWAHeTXe5sKDvdtM0hew5fg
         wAmuWHEIW1nRoO130+HUBxJslirDRqs9wOA1HVdpB4YLq5xw3oR2bNJb4lKZ0egiZXiM
         WQYAO5tj1SoMyJCPy87Xi2ICjzQJWS3gAi1TPnvlkso79Rc2DNQwb496yxMdJZxh2pvY
         NAaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from smtp3-g21.free.fr (smtp3-g21.free.fr. [212.27.42.3])
        by mx.google.com with ESMTPS id e9si6838305wrr.359.2019.02.12.07.27.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:27:02 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) client-ip=212.27.42.3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from [192.168.108.68] (unknown [213.36.7.13])
	(Authenticated sender: marc.w.gonzalez)
	by smtp3-g21.free.fr (Postfix) with ESMTPSA id 45D1F13F8C0;
	Tue, 12 Feb 2019 16:26:10 +0100 (CET)
Subject: [SOLVED] dd hangs when reading large partitions
From: Marc Gonzalez <marc.w.gonzalez@free.fr>
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
 <690af800-1cd2-3e68-94d9-bc4825790837@free.fr>
 <493e04e4-849d-8f25-95e3-408f775fab64@free.fr>
Message-ID: <734274cc-d22b-5fe9-1650-b13c692c5b9d@free.fr>
Date: Tue, 12 Feb 2019 16:26:10 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <493e04e4-849d-8f25-95e3-408f775fab64@free.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/02/2019 18:27, Marc Gonzalez wrote:

> A colleague pointed out that some memory areas are reserved downstream.
> Perhaps the FW goes haywire once the kernel touches reserved memory?

Bingo! FW quirk.

https://patchwork.kernel.org/patch/10808173/

Once the reserved memory range is extended, I am finally able
to read large partitions:

# dd if=/dev/sda of=/dev/null bs=1M
55256+0 records in
55256+0 records out
57940115456 bytes (58 GB, 54 GiB) copied, 786.165 s, 73.7 MB/s

Thanks to everyone who provided suggestions and guidance.

Regards.

