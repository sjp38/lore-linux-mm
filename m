Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C51B0C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:48:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B5572177E
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:48:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WtlE+P3H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B5572177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AB056B0007; Thu,  9 May 2019 12:48:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 259976B0008; Thu,  9 May 2019 12:48:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149256B000A; Thu,  9 May 2019 12:48:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA0706B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:48:06 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id v3so3164067qtp.23
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:48:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LnyOr6ZjvYu5ZxnoPdE4jqzxN1EqnDnnop6FdcNjWUo=;
        b=npkKHgoxemQM5U1xnyiPWeSsdm1PmM5OfEgBFKab1Ve/AR97jaoAhMjAqh4dgozYOc
         T7QYrwMRsSw+oqFPU3Cb8KiIqA4ZR/NUFeMVEFzDs39dzAYo3OZTBhPNPY2w1Wre3R8M
         +KK7qR8Rnko6Sdi/m2t09mbA2e36PvfzaXIa9AgWm9uW9NqhpiwoHxYDD2+dKYN2rj93
         zCvl0ozOY8fqFnWJ/t9eb78/HMGK3/AQXB71+Ril2YBNSrhGzNHrboZedgtfs4KhP6ks
         McWJm5jOWHjdOEcz9bTUSyJR0tUc/lKVEmAQGdY+tk8HCdFI7P/xAmaNEEk80+Op/nkm
         GzzA==
X-Gm-Message-State: APjAAAUWJN8M90RKYCtNKJ3QiZeQESUIv9B8u3lX4EnpesnITg9VNE6j
	b0SHfu7b6s8cUvChI3im3OipPtMzEmOpQEhwgfPOvxe4Tducb4F6491MGY1PfuyMd0/qpps7Fsf
	/JtR/SCwDNC0jcFVbBXD34Ykxm49/Q5ruEeb5+2F0c334CU6PBdXTpkPu2egjZA8=
X-Received: by 2002:a37:6291:: with SMTP id w139mr4231777qkb.285.1557420486570;
        Thu, 09 May 2019 09:48:06 -0700 (PDT)
X-Received: by 2002:a37:6291:: with SMTP id w139mr4231719qkb.285.1557420485915;
        Thu, 09 May 2019 09:48:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557420485; cv=none;
        d=google.com; s=arc-20160816;
        b=hsv3+dFvYoyfZQIyRJh3Z3fqHzPQrINQcaV3iFIWyAISzPKCUBuyyPp7Rpch9U6ACi
         tt+LXfbteaEeheXxW2nYmOM06q2b8X0SBrKb8nZ1OTc62Std0YrpQPhbPNOV9tDjSzn0
         AyzTzZJRF7vO+Cksi0uysBrXjrUyIoKsx1BvBubj/on2qZQeSAeQ3jG/s1qLV9fa3ydb
         jzmcA6g6wDv5+3sYbG1m8NFTFTYpOhLMOB2cWCd9IeZmmdigQkHQIC6UqD0X0JcQEMM9
         4Gna0jaAHXajWURUvwBZwDVDaOASbwYoqRozL5Q2KXzEkXsStZk7Okp5xoTGjbxc5meM
         uJDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=LnyOr6ZjvYu5ZxnoPdE4jqzxN1EqnDnnop6FdcNjWUo=;
        b=Ojr04NIxkG4bNj1f1L+23xWPvNCfHFKQxJiwF4rhfAD/pd30wbTnFBAlybiJoy2QQm
         P9UYiDEy1Nq83DDM2lmq+P5K/eeyqNcKpBKYR1gGp+YsTN4gictPZeT2izWJcXnFcgBE
         yYSCIZvaw/8vIFEBw4RkvXP5mi7x0ah3ZZsPBrupvie8zNXg6iOEqTrn53NNMutSmQcq
         dcOBjiefveCEB4uXhPJ4V08NNf6txc5LvByresDykcNaZaSnKC/VAtId2XJriJtFwQYH
         /7tOUA7TA+LqAtujnLTI79A+48WRyMkDpqpaAaQNA46fQ22xmnpcNzG5dTc3JdrYKWlv
         Sj5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WtlE+P3H;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i125sor1474418qkc.80.2019.05.09.09.48.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 09:48:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WtlE+P3H;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LnyOr6ZjvYu5ZxnoPdE4jqzxN1EqnDnnop6FdcNjWUo=;
        b=WtlE+P3HplSNzxMK41/9RDh/agT6ECvTArx0nyXfmTrqPeHrI1dlhmlFbPSfGkf1XZ
         EYVC00Ie/P5VHI9oUnao//YW5RN8bj/xIucPH7Q/LYeBAdXtCUCS/XxnY7WS+mq9dW2i
         5lwvj7qHtwSwBTEOzvM2SvOlykhHzpReUEhhvVvxi0Hfp2iyuYjfZAWqy7XHNGKTYO+H
         YAyFa3LhmBg1NdPHNsxPtPyrL2XMHNUoFsOsh2HSY1Cgn+dtXhVzNfcMhhrJyrnofCCa
         ZvZOw4hQFIjgJEZjHFxoAk1Ys0ZUq4sSZLUgfd31jwkZmUizT8dr7fLkoPKDGCXNyHpL
         V+dg==
X-Google-Smtp-Source: APXvYqxj1UpguRUHZlnsD2pdtF8y8Y6jpDdLG+5qOZpB2lOkj/swrowMpce7P5mkPHFxmjEnZklzJQ==
X-Received: by 2002:ae9:df44:: with SMTP id t65mr4225788qkf.126.1557420485515;
        Thu, 09 May 2019 09:48:05 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:c346])
        by smtp.gmail.com with ESMTPSA id m31sm1466763qtm.46.2019.05.09.09.48.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:48:04 -0700 (PDT)
Date: Thu, 9 May 2019 09:48:02 -0700
From: Tejun Heo <tj@kernel.org>
To: zhangliguang <zhangliguang@linux.alibaba.com>
Cc: akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] fs/writeback: Attach inode's wb to root if needed
Message-ID: <20190509164802.GV374014@devbig004.ftw2.facebook.com>
References: <1557389033-39649-1-git-send-email-zhangliguang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557389033-39649-1-git-send-email-zhangliguang@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, May 09, 2019 at 04:03:53PM +0800, zhangliguang wrote:
> There might have tons of files queued in the writeback, awaiting for
> writing back. Unfortunately, the writeback's cgroup has been dead. In
> this case, we reassociate the inode with another writeback cgroup, but
> we possibly can't because the writeback associated with the dead cgroup
> is the only valid one. In this case, the new writeback is allocated,
> initialized and associated with the inode. It causes unnecessary high
> system load and latency.
> 
> This fixes the issue by enforce moving the inode to root cgroup when the
> previous binding cgroup becomes dead. With it, no more unnecessary
> writebacks are created, populated and the system load decreased by about
> 6x in the online service we encounted:
>     Without the patch: about 30% system load
>     With the patch:    about  5% system load

Can you please describe the scenario with more details?  I'm having a
bit of hard time understanding the amount of cpu cycles being
consumed.

Thanks.

-- 
tejun

