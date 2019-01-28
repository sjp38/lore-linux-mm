Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F0C3C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:20:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52DC02147A
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:20:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52DC02147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8A8D8E0002; Mon, 28 Jan 2019 13:20:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3A498E0001; Mon, 28 Jan 2019 13:20:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D03F18E0002; Mon, 28 Jan 2019 13:20:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9790F8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:20:58 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so12314318plb.17
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:20:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=N/L/9GhZefvhIbNzmPmzWZE8ly6u08M/YuT6KkZeo+k=;
        b=K+3RJiHuqNlvO82gEvpDKyzqdZX0dgotflPY9FbS3Ii6tmE8Pqp1fYaQceMECmxfd8
         UkEjn/Lvljbq3/en5foS1nRmlzSI5254om0ZS+gWxA2NiDWufnJTceVdiaZEog5xnEKB
         HkUsYCoSBxVEQyFf5feY+zMugmMDbrU1s5FY2iH/8EWIcF1Z6ohiLP8qzeYFm2JejpxJ
         XNJlSCplN+8GpHjibfrMSRHmB0gi+NYVbCZHC+FjtUbsnyFW2R1QIA6A4HeKxjvABIdz
         jPwYDvyjA24/TZuVg6U9SY0gfAQZooJsR7pmefG6ymBcA1zHdSoFYQ+MkzBLc8CS+ZgP
         n+Bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeZlEgarC2i7Ps3fhp2kIc9xaGYAgeyPFbey4Z0WT/3dshptGed
	KuJjs6L6yNUk8zOddqGir4eMeojphDNCOvMo2FjpuCxxYFcKN5XYkrd4umPSobwcbA0/rdh6YEN
	tZpe+H6TxjaWDXTc3I+2AYiOaoKr7mxizUTeheg6kWtgrRBoEX5pPmxxc3TCe7ToBtQ==
X-Received: by 2002:a63:441e:: with SMTP id r30mr21011971pga.128.1548699658305;
        Mon, 28 Jan 2019 10:20:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4BWTrNsUHalR8T2hD5juP6Jas2dcy0H7NiYGb18kkbWuxuZ05sdecT9TBqsRCai9PqYuEU
X-Received: by 2002:a63:441e:: with SMTP id r30mr21011942pga.128.1548699657677;
        Mon, 28 Jan 2019 10:20:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548699657; cv=none;
        d=google.com; s=arc-20160816;
        b=qBGqXu9eccXipI6iWPnptcgcYf4kovvpCdKChGvBt6QwKyU0Tw4wQzvs4JDlD/91We
         /dR6nBmajm7qd9mDUcfPn8x9IzUcNHW5cRaS5SMb5OW/HqNNH89y3BiMiqrNwQLFR3yd
         YgPFBmQnvy8Q4lWfExzpbHIYfgMw/89jCZmRd0dHCgpPO96RH7ZFdOxGK+sQzI/wD4Ka
         9e+UgMhI69rR+fw8mtC+X95X4WYgpAh+NeV6T1lHlgXK2xs5rvy6arNGuIheA5OE58ub
         TBhepu7D1HX1BjMBBskgVRoaPrzTZ1WNd2ysdef0B8JZOWPr/x4Q1V4KJbg3JmA+urBg
         1Lwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=N/L/9GhZefvhIbNzmPmzWZE8ly6u08M/YuT6KkZeo+k=;
        b=iZIkLkRtE2IfLtRv3kShvTCndzrh1sgoY6kLeUC5WQe5zNJ7kCPoBWJVCxmmMINUR0
         G071g5XajEwQOgDrtlbCfEJD19rSBCWt/dkdGhQcS82+LwjCvfVjNP7oFJPWIQjtMi5G
         mTccppToOi4uOLHacoTEtXhbIi7MvdlFjWD0cCp1WpdVTnB9MakrweJLKFJLfuv2/xBG
         Evi4rS9NkKwd3D0aGQPD66nVR2fZ39m6WQ5Ibezcb0jg6ATAy7TezGo7z90BJDomlL37
         4ypAEI6bVEMQX66QgQdyt1iEz4cTnu1XCRWVuRKdnUzgV+7gXc/nasb0w19tzSzpvmHe
         glMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d15si14451235pgt.498.2019.01.28.10.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 10:20:57 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 1228223DD;
	Mon, 28 Jan 2019 18:20:57 +0000 (UTC)
Date: Mon, 28 Jan 2019 10:20:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel
 <riel@surriel.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
 <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, kernel-hardening@lists.openwall.com, Kees Cook
 <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
Message-Id: <20190128102055.5b0790549542891c4dca47a3@linux-foundation.org>
In-Reply-To: <20190125173827.2658-1-willy@infradead.org>
References: <20190125173827.2658-1-willy@infradead.org>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jan 2019 09:38:27 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> It's never appropriate to map a page allocated by SLAB into userspace.
> A buggy device driver might try this, or an attacker might be able to
> find a way to make it happen.

It wouldn't surprise me if someone somewhere is doing this.  Rather
than mysteriously breaking their code, how about we emit a warning and
still permit it to proceed, for a while?


