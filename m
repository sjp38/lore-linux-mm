Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1066C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:28:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6766F21872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:28:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6766F21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C7228E003A; Thu,  7 Feb 2019 10:28:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 075F78E0002; Thu,  7 Feb 2019 10:28:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA9A98E003A; Thu,  7 Feb 2019 10:28:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B76408E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:28:09 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id t17so109183ywc.23
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:28:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i8V5xfPXnRktiKaBdwpRTMWn5k5v1yn8ry9ZD3Lhplg=;
        b=kR4h5VsGyk2Hha8+sRoVzbcWbEXEwLDXAJthhomnTT2tucU3oFaBMgwJxLAvTGcbcZ
         n8ETdlq/XkbyvdFEfnoLWFAO9UgyfB4BPodUH72EYVruFfPjS6Q9vxX043iTNfcpsbrr
         Q6QqPYXImagHwjfcFUEJC0L4ZjZWs80ZNtvP1Ook/+inNE3TWqKAdYcjzMhVPpUSkrJ7
         Ak3Y+mAgOyiBpHSEVHPd/rrblMEVxYHxdRsaF0VUSSSiTV7I01WATooE7a6+jfPLn7bd
         n3MZf6WxfJrcDeyGKnuhdARpYmme6oUJsy6KzwqC+jl0o7NaWWwpbaCMWhBtHJCSBXec
         Thzg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 68.178.252.109 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
X-Gm-Message-State: AHQUAubc9A2yhr6zwyah5vzxjx8h9XS6GXuTAmHu4ShBFJfkiHXAemiD
	xppGDMs4SaKS/71rBea8gfltuAEKxTnmJ0G9Kfd6XyRy9J8/uOwBekrfdaVzWDagP6ucr1rKMA1
	Mtmjo64VbApwPG1Ms46kNL97z83A3IQpq6aV9oeCtDWoZTvW5J8HGQD4GZ2ESp2I=
X-Received: by 2002:a25:2e01:: with SMTP id u1mr214038ybu.241.1549553289435;
        Thu, 07 Feb 2019 07:28:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZqnDb62D77ArICLmcHDx1L78hO5OkTVczQpoj1pMcUcrNRqCTNSE2rHOl5GJhrSdRI2PV
X-Received: by 2002:a25:2e01:: with SMTP id u1mr214005ybu.241.1549553288792;
        Thu, 07 Feb 2019 07:28:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549553288; cv=none;
        d=google.com; s=arc-20160816;
        b=w0jip3jpOZB6UJvxsRDlwe2ngyrXs87uk2SbGMBjZ1pCCMNtX1yIrk/DD7jk38AWqh
         87Bb/QecFGnwsRvbE2pkks5HacedTLSf90lPuRhye2r2pHxwqP4Sq5aPo3ttnV3dgdwf
         I9U4jxLl28SxUaui38eIF/WR9FMhp+rjeOv83XcTNvp0zTaRaO3YloS8iVHBoSsks+JJ
         emgpElKP7P7gRn58u9kJlbZlBNpjbAqukvnmOItRvAJDS9xIwOPHEvJLpw7m3Mm3zkC2
         NGEHie/zr0YyC71UbxT2zHzVAPikMmp7BcNpMV4o9SOHR3Fazllr70OMjZIlsyr+B+qT
         q+WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=i8V5xfPXnRktiKaBdwpRTMWn5k5v1yn8ry9ZD3Lhplg=;
        b=Ep6kZxRwbddB1X5jojSJG1+IqmlaW5YZo5AOpdWsoQP/EcLrXDZNwv9gg63bLwxk4E
         DzTvM5vYNyrNfciam4BBxqqNPMT7sI/RyGfCD1TRd16BiF1Oc4MDR2oICOHxITaRdgjf
         GWY8ux+ZZ8H6W2P1lZwfHAw3QtCRktDGiIiirrcS5J5WgaPL+c2qse5C/bSRvc+kIzUU
         7a3JDkTFsisxMkUhuD6ngS5xUX4n3c/q+giAmLcAVj26MIEYt3naRCFTNqF7M8xw2AqN
         k+XnO9uXxID8mHLLV+MG7MjgQOHFYaMLvLCM0oXm/aMssCYNJh9HCU56LNmx5f0I4pHh
         m8bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 68.178.252.109 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from p3plsmtpa11-08.prod.phx3.secureserver.net (p3plsmtpa11-08.prod.phx3.secureserver.net. [68.178.252.109])
        by mx.google.com with ESMTPS id 199si3331306ywg.333.2019.02.07.07.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 07:28:08 -0800 (PST)
Received-SPF: neutral (google.com: 68.178.252.109 is neither permitted nor denied by best guess record for domain of tom@talpey.com) client-ip=68.178.252.109;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 68.178.252.109 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from [192.168.0.55] ([24.218.182.144])
	by :SMTPAUTH: with ESMTPSA
	id rlawgLepiwjkSrlaxgg7RS; Thu, 07 Feb 2019 08:28:08 -0700
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Chuck Lever <chuck.lever@oracle.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>,
 Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>,
 Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
 lsf-pc@lists.linux-foundation.org, linux-rdma <linux-rdma@vger.kernel.org>,
 linux-mm@kvack.org, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>,
 Jerome Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>,
 Michal Hocko <mhocko@kernel.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
 <CC414509-F046-49E3-9D0C-F66FD488AC64@oracle.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <6b260348-966a-bc95-162b-44ae8265cf03@talpey.com>
Date: Thu, 7 Feb 2019 10:28:05 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CC414509-F046-49E3-9D0C-F66FD488AC64@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfPmGw0S/F+jDO8g9TI6I0AGVd3YdUEdJMypisormobzYqhg1vWdAg/NpqGfQL3cRG2lHaF0XRt4zsriqihSi4afMFgHZM/lQLC55kRYTXgyM5cpXECIC
 h+wlXyoX7NjzjRrqohfrZ4/GhyErIZexlTuxAaL/hcvkjSr1Zj3+XWmTIobKTpuACOj3CU8x9A5t7QRDI481w3uL0IgqddjnxZyBurkrrhK9a890d4nNcSRj
 fT0cPB4VV2jAydi9WDw1VOG7iCtKWjCvXu82CpVm/6VO8aSHjrSr4uMsYXy2igUQ9XtedyDWEpvdMMGM7r6gUtzIqFhWfoAU9SdDEh0sbz19jjL1uhLSHPCc
 7QNm4hdauLmJvQTuGl4U86K5nqglhD8XevIwYfwSn/T05ZDzLWxH82/GCT2xwzN9f3OO08RqT4cYPVpzsltCGotxIrM2IsH+Y9UpdGUmnOHe+jE6cTal/1vs
 rTjWs8YA4twyDaq93AispoAcxHJBp0NddBKccyvxyV0CA7Yhfp9RVqenzYQZAYGYFhSCSJ2n5Tw/YB0MZ2mwVmdPC2JUAp9tZvdsjpFGxhzFN7uD4CN6MDQy
 uyzjgTk72rYNMDFvUYJoQYYBDXPyn+XA2+G4ysDdoHYaNedFXMdCWRnexqKzyiTNyak=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000010, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/2019 10:04 AM, Chuck Lever wrote:
> 
> 
>> On Feb 7, 2019, at 12:23 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>>
>> On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
>>
>>> Requiring ODP capable hardware and applications that control RDMA
>>> access to use file leases and be able to cancel/recall client side
>>> delegations (like NFS is already able to do!) seems like a pretty
>>
>> So, what happens on NFS if the revoke takes too long?
> 
> NFS distinguishes between "recall" and "revoke". Dave used "recall"
> here, it means that the server recalls the client's delegation. If
> the client doesn't respond, the server revokes the delegation
> unilaterally and other users are allowed to proceed.

The SMB3 protocol has a similar "lease break" mechanism, btw.

SMB3 "push mode" has long-expected to allow DAX mapping of files
only when an exclusive lease is held by the requesting client.
The server may recall the lease if the DAX mapping needs to change.

Once local (MMU) and remote (RDMA) mappings are dropped, the
client may re-request that the server reestablish them. No
connection or process is terminated, and no data is silently lost.

Tom.

