Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48B18C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FB3C2083B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:44:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FB3C2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=opengridcomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C6788E0002; Tue, 29 Jan 2019 11:44:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8741F8E0001; Tue, 29 Jan 2019 11:44:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73BF18E0002; Tue, 29 Jan 2019 11:44:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF218E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:44:47 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id z6so8020318otm.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:44:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=3sYl/7gEMvShHwWIg2qEK89zeqoWynQRLaplUQrrcS4=;
        b=MOr9vlBcp3E4+RnxkO/KMpInOR9jsne6pUHDecIHuFLsHs8WaZyU7zea37CgCg4+gk
         sXPxkycQgUA5iinGuc5FHAOeJGOms8t18fDHE1Et/cZ+C8qqX651QC9qBpB4Nc56ry4D
         5sR2GZ9e2dfl9tdlONwV8Ro6jEoGwBBKTeOg2mqCyCxwaGMfvTKEaWY0eY6U4ZyRzGEb
         YQ732SZlrkHXI8CQIYtsxivpggetURN56uPCS9lkBwh+5roFb0L84UjzgJ8mubf3O/ja
         WI2fUjfu/dSqzwHFDnlj51t8Zny4T/PwYcOCdtbEtr+JMW+s8u+0UaxJfDRDnJu2iYac
         Z/3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of swise@opengridcomputing.com designates 72.48.214.68 as permitted sender) smtp.mailfrom=swise@opengridcomputing.com
X-Gm-Message-State: AJcUukddZ6LCv6ELBZIyl7FMHaZge9BfE3f3miro81h1C9IjVn2MFLu7
	0SZCfJIV9sm2vXe/6YcgzDmBrvvrXBkdBxVeE+HdbQ4igwKijT6cjJvcGQ84QiWgWveXuy3MwfF
	z3jT7OiofFXIxdIyVaH4CwAQHsWgRhzH3gnXoQwkJi3Aid4+n+krUO5tng2K17O6coA==
X-Received: by 2002:a9d:46b:: with SMTP id 98mr20572334otc.339.1548780286882;
        Tue, 29 Jan 2019 08:44:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6AJOH7fYGkqvmFBmgfIHh98gFFtOe0wDIkeDtEwm4YzyjmoJMwGcBTpIoNDdcjv2yYJwAw
X-Received: by 2002:a9d:46b:: with SMTP id 98mr20572310otc.339.1548780286352;
        Tue, 29 Jan 2019 08:44:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780286; cv=none;
        d=google.com; s=arc-20160816;
        b=catdk4yHnkkh+FAgucsrb9fQ3W96RurVwp9eK4tl4XVO9V9rKMqhEC+Z7Cr6H22war
         a7ihnEq+ozyyguFCkxVPdouijw8/NgMUjNXg8X28ZBAucpEu3Vq+4jklmIL0v5vpH4sH
         rWXWRgDYkJ+332nDscsR6BrhD390Z9OOmlXHpXvc6y4AoCCANIu+TEeHzuIG+5etJoFc
         xcCTFRJyBVf+A5f7qK+mLVytHM1l733Qf8A8uuvAK2uKMUeUJ0sELwOfIZMNxZlryvt+
         Eo0y8K+vdVPg/H/hRVq6ijC+EqTpsuoq8IwtHetu2+ADMo5b1p4/BMKbBboRpgDimc3b
         xdPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3sYl/7gEMvShHwWIg2qEK89zeqoWynQRLaplUQrrcS4=;
        b=BBzp65hHwSlrozopZ5A4WG+EXY3Re40o0HY001U73KZQUqDLj94QcfXl6GrcmD2dVW
         g61bH2dyTwViils5dW9B4thh5KbLlQhH5m/XL+xYRM3SlY8vN945p6h6j+0JtIHlCFyy
         VOZIIilpiqfRRgBCbcA33e+i/MOi48dwdPBa5qoAXIowl2Wo/6zxKYdJBaBGA0jybIrn
         asxb77rVM6oKIkrvHOSTwqfi2EeMaqCEHBE8FtSogAyOR1HB/ktWlzUrHKzrTRcSGaNb
         EMqLU+lCAI3h5LXtuiBzx2NgA33WTT2Nn+mpZT7jFQU4C+CqFW4I1dSnQ/oQnkm7zNvG
         v7qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of swise@opengridcomputing.com designates 72.48.214.68 as permitted sender) smtp.mailfrom=swise@opengridcomputing.com
Received: from smtp.opengridcomputing.com (opengridcomputing.com. [72.48.214.68])
        by mx.google.com with ESMTPS id i3si6603942oib.163.2019.01.29.08.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:44:46 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of swise@opengridcomputing.com designates 72.48.214.68 as permitted sender) client-ip=72.48.214.68;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of swise@opengridcomputing.com designates 72.48.214.68 as permitted sender) smtp.mailfrom=swise@opengridcomputing.com
Received: from [10.10.0.239] (cody.ogc.int [10.10.0.239])
	by smtp.opengridcomputing.com (Postfix) with ESMTPSA id B9D0122666;
	Tue, 29 Jan 2019 10:44:45 -0600 (CST)
Subject: Re: [PATCH 0/5] RDMA: reg_remote_mr
To: Joel Nider <joeln@il.ibm.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: Leon Romanovsky <leon@kernel.org>, Doug Ledford <dledford@redhat.com>,
 Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
 linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <8cdb77b6-c160-81d0-62be-5bbf84a98d69@opengridcomputing.com>
Date: Tue, 29 Jan 2019 10:44:48 -0600
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 1/29/2019 7:26 AM, Joel Nider wrote:
> As discussed at LPC'18, there is a need to be able to register a memory
> region (MR) on behalf of another process. One example is the case of
> post-copy container migration, in which CRIU is responsible for setting
> up the migration, but the contents of the memory are from the migrating
> process. In this case, we want all RDMA READ requests to be served by
> the address space of the migration process directly (not by CRIU). This
> patchset implements a new uverbs command which allows an application to
> register a memory region in the address space of another process.

Hey Joel,

Dumb question:

Doesn't this open a security hole by allowing any process to register
memory in any other process?

Steve.


