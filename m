Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEB25C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:13:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E9DB2070D
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:13:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jQUDIRp0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E9DB2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C8AB8E0103; Wed,  6 Feb 2019 18:13:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 350EA8E0007; Wed,  6 Feb 2019 18:13:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3228E0103; Wed,  6 Feb 2019 18:13:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0A908E0007
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:13:51 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id 201so5614037ywp.13
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:13:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:to:from:subject:message-id:date:user-agent
         :mime-version:content-language:content-transfer-encoding
         :dkim-signature;
        bh=oYyO4T5HGVHErAqxFlUdaW1I6t7x75aaEnbs8E4YeTA=;
        b=Ue92T3xdFJ28nI6jgPDtaqbbc47dW0CkR02HuK4iRz8On39AL95m+eveKggBABwq0R
         Jj/aL/HapSuEzohPq30mykXy5/xrEOnG3yAjniZ47gyT4Ti4/Pgr7i76C9dDvRrb3mUP
         7w6rnbOAI9S3MLFgmIX9rgv4Iiz4erH71CrfL1tOiBWkZiA4DtLQnix+uTtgLRBfoOGr
         HcBeFCT/H5SBZQ8DpyupTfEeWK7UtYD41Kxw6RcjZD1xtXz88SLeE6fBnNGQMZLtQNgd
         SjMfkiYH2Sp+noAqMROFzhdffIiWHy4XtuiBt7jf5FAojJTKbf1x6FvCsdTC2hqbkLjb
         lyyg==
X-Gm-Message-State: AHQUAuZZJoITk/B9JazBBgI2yMVQNB6zQIS6b/PgPQnNjVU3v66envJm
	XqpvkbBgINkkT5sMFMmuCLkcinYaX6dP6c9pfsZoUraHFinEPR1UrCDeI1lPTtcCJhmlyfmKtbi
	AJrNs+hMu+Yoifgk0xQE4mp1ATlbe3NhfY2lydeYfsWPVLV62u7yOo5mTsGJDubMGDg==
X-Received: by 2002:a81:5510:: with SMTP id j16mr10376650ywb.207.1549494831445;
        Wed, 06 Feb 2019 15:13:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYXRKsXfIezW65YNv6j2cpBwiu7w1KmA+NkWcmC7wbeEQlxmQA0GBC6NksBcUPVX+2gXSo4
X-Received: by 2002:a81:5510:: with SMTP id j16mr10376613ywb.207.1549494830744;
        Wed, 06 Feb 2019 15:13:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549494830; cv=none;
        d=google.com; s=arc-20160816;
        b=KWteDHWqZaaZkbjPO7i5cDYIe4jWkKM2YPl5cBb3hMDsWWe4fAhTw7TJOKNx9/wXpA
         wJn6koFO36dfUTTCrpo/R58aOEEYRA8NMz1xuQNBXUUCy8Z+7mHz5n+uyRiNc3k8E/HC
         WxjBmvoyfQ4Lk34Ko51fQT8Z+nxFQCM/EBYG8otDmsRaEnW6aGuNaJvB9PDti2Y4WfVJ
         qepzRrnLIbfOZ3gGOs9+hoi1PTXtF5EQgTMdPkfidT6e6cvOlmA8XnvXWpwr14RNe3ee
         AvJDG9glp1GVtKcCEZmqpF8LaH5/inZv+Wlb/MF2z2p+tos9T2E/nGtH0/Sl5I17OSlK
         GUmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :mime-version:user-agent:date:message-id:subject:from:to;
        bh=oYyO4T5HGVHErAqxFlUdaW1I6t7x75aaEnbs8E4YeTA=;
        b=RKLJTscan2F7hCJZ7DdrynrsSYsrkBYo0EtsabfhXU1ZzRqDhFjRAnr/xigpIKeEKA
         OMxwIlZtGn9ShdNTAPl0O+JJrP52rgweszs3etRhU5ag7yUGOJouyWkXs2bhEPggO270
         fHEKwQZwdsaB3UsFH+QIebJ9Ofk6a8X2OkjVih6KDXHg7GiOgUUbK4zxd8pU1/gEYMgf
         nV+jgxOpK86NxQjaz0TpLbih9oBveYfHb2WvinPTb53HxsADCfHis1NYVTxI8U/UzjrI
         f/60fn6NMF/YeIu4izbab/PyGhuD19rW4GfOBx59NhzNCZkrZiG9oF9OiGnbC2mnYCwR
         a1BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jQUDIRp0;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id c13si4443574ybq.341.2019.02.06.15.13.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 15:13:50 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jQUDIRp0;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c5b6a1e0000>; Wed, 06 Feb 2019 15:13:36 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 06 Feb 2019 15:13:49 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 06 Feb 2019 15:13:49 -0800
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 6 Feb
 2019 23:13:47 +0000
To: Linux MM <linux-mm@kvack.org>
From: Ralph Campbell <rcampbell@nvidia.com>
Subject: No system call to determine MAX_NUMNODES?
Message-ID: <631c44cc-df2d-40d4-a537-d24864df0679@nvidia.com>
Date: Wed, 6 Feb 2019 15:13:46 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549494816; bh=oYyO4T5HGVHErAqxFlUdaW1I6t7x75aaEnbs8E4YeTA=;
	h=X-PGP-Universal:To:From:Subject:Message-ID:Date:User-Agent:
	 MIME-Version:X-Originating-IP:X-ClientProxiedBy:Content-Type:
	 Content-Language:Content-Transfer-Encoding;
	b=jQUDIRp08YIHBNWHu1qvaI7kN22lzklcHgFI+Dou13n1jPm8/2UQ07+ZPueFhDWh1
	 7omxON/BS6f39ypw62moljUmWzzMP7FnZE7OOBC56uqZwfXdTbfKMrcrOhPkNMCKp5
	 iCYuE7pAHx8Ko0iEFgCiLEIOmkHvO5gj6D6TFG2Byo0b9o0pujMvOYIWLHEr4ZeoAW
	 DHgI1pkxKTKbhJZ6gD+1nAMxOX7xwpcDyad793w7XkChnF3308u/ZW+ERp+OdLvV+j
	 4GYIgtIzq3Mwgh8sP4dnNljBwJ4HWXjwx8pZ3NaX0m4/aRKjYCYREhj7W979gRbEUV
	 GMwYpUunQiRiw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I was using the latest git://git.cmpxchg.org/linux-mmotm.git and noticed 
a new issue compared to 5.0.0-rc5.

It looks like there is no convenient way to query the kernel's value for 
MAX_NUMNODES yet this is used in kernel_get_mempolicy() to validate the 
'maxnode' parameter to the GET_MEMPOLICY(2) system call.
Otherwise, EINVAL is returned.

Searching the internet for get_mempolicy yields some references that 
recommend reading /proc/<pid>/status and parsing the line "Mems_allowed:".

Running "cat /proc/self/status | grep Mems_allowed:" I get:
With 5.0.0-rc5:
Mems_allowed:   00000000,00000001
With 5.0.0-rc5-mm1:
Mems_allowed:   1
(both kernels were config'ed with CONFIG_NODES_SHIFT=6)

Clearly, there should be a better way to query MAX_NUMNODES like 
sysconf(), sysctl(), or libnuma.

I searched for the patch that changed /proc/self/status but didn't find it.

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

