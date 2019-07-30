Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D07FC31E40
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22307217D7
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:40:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bE9C7hLQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22307217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2CE18E0006; Tue, 30 Jul 2019 11:40:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A041B8E0001; Tue, 30 Jul 2019 11:40:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F2388E0006; Tue, 30 Jul 2019 11:40:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 590BB8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:40:02 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so35538698pld.15
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:40:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Vne3d3TA+jWKXpZqNUGuJSIWUSkOrA0rq1xIX/cTwsA=;
        b=h/KBoXPXzPggX9NeUThAMeO7L5IQ2NvBt/hzm8EOTeKb7wP0mpQQIx9niVdP8Pg1aj
         LlfX8E1qKoikiadywUPqi2TR3yDO32epS70gdnQKxZnR6zmsI4Pw9hD0G7ka6e6hdETK
         R3iLqJXhXohLBZiWa8kl2oyhFH0QNE4DWA9OnuOIvyav7491I2LxfK5moUsvt7GdU/2l
         u4pBD+PLfHZjC1+OZcVpiyIL6kTBAaswS+17RzXYOtSXjb8sS6UfcAvFboXvyLPMFHgI
         Q9epB94pByibMU8UgobHFgHQGu2tHzTrTPl76gF1bllS4Vbnk4uV6ODDDposThEu0HY4
         fJrQ==
X-Gm-Message-State: APjAAAWS2cKeAVdPUajtFsFCDcBCxy9t3/LU6V3HrmDpES+r3vx2p1jk
	E7F578j/yjmaKlZySxJJAjOMrxwFmwp2LO6tt7bAhTjf6pyw5B/cACf5YAHsItLvrcZLSIkSbvF
	J1UD+vp/oKXkmwtJFMrt7mRgo/04JnFlpO4hug0dDB/HzXEG/xvKorq5jtr667GXwYQ==
X-Received: by 2002:a63:6154:: with SMTP id v81mr75616039pgb.296.1564501201877;
        Tue, 30 Jul 2019 08:40:01 -0700 (PDT)
X-Received: by 2002:a63:6154:: with SMTP id v81mr75615979pgb.296.1564501200831;
        Tue, 30 Jul 2019 08:40:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564501200; cv=none;
        d=google.com; s=arc-20160816;
        b=SgDx7ix2ZJVUdiYialNbf6ZvYa9LaOJ6nPQpxVc7yZNEj4fB1fmLniz7vAIcoZZ7oY
         B0lNW3lR6D+PexYfx7w5lQ0vBnPVvqZyHMfOOt2d4aAeSPAJrGlrkFHs6AUIzzVlznVT
         6xuOIMnOZT1n9fU5jEQbA85TzD8MIXm6lg94uFDdHLY6nnZbN3EJtsN6qYN8K0ZybH34
         QB1NYQlyIMX6m3vcJbIfdhXev/c1TqVt8XAxZ1caeU4+vi8rQa+vUfP3UCI0Qo95xLgj
         mAJuW9tj/QTg9m9i8IyronvJK7cxYrhH+BYZl0NhHfWPWV/+MC8ISJSxw9qaMlx4lzG8
         n/jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Vne3d3TA+jWKXpZqNUGuJSIWUSkOrA0rq1xIX/cTwsA=;
        b=K+fjFW7UVwvx4Foc83D6jgT8uoJAnzu5JPoRYPjghrhcxxMmOJPyG+rWOF4pA6zJWH
         MpBANWX/Oer4Wr2h1h85Dy7vqe7rKZYdF1lhCLQx8zwVilL3IMIFM0ZGSDe0rHorJeek
         eBB87D5i9K8BGe3a3xf4UQXIedjR3Q7n+7IQ9GfhWLOmjNtAE8qiRvUbWtQUJVdnD8fN
         gVUNq/eV0Ux46IPfx9V6JtUPY1zDUIAQjXfsu2cYT0AxRYsjyz4MrwCMSjvkTq/D6Bsd
         YyOAcQA15SJzb+zgRqcw1+lfDkEILS5k0zf2CjdXnjJ3VJ8ICxkvuXwxRbVV6pnU8/kK
         5Yzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bE9C7hLQ;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f16sor42042701pgn.77.2019.07.30.08.40.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 08:40:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bE9C7hLQ;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Vne3d3TA+jWKXpZqNUGuJSIWUSkOrA0rq1xIX/cTwsA=;
        b=bE9C7hLQeEeAAUDM9brsj+v0BgqdDlJPXOYFfQA7UDpv0VvD6Y/2S6ZhkRIIv8T8rm
         cYWT7A4X3TCY2CBLDcVhBdroKpeZX41WVhh9pQs712L6JAkZ0anqmNse11vvfVLKO9H+
         gGpskm2MFw1lBkTjETkNw0/kMirfacfyYcHAEYs9iZ9qZmSeBk4MbyvV+6QGa4KFhjva
         eYNdgMH6IRAVJ+iA3fFlrC7+gBzqn4n+3Qo5XGj3+u/0SK8QQ6DGloJosb3XnYtqMnVk
         QwmhLsMCc4b+NtQXC5oZp/DzXRN1pP2f4egg6OayFiWdQzVcONmDUnBpZCx46fSa4QkU
         yRSw==
X-Google-Smtp-Source: APXvYqxiu60GFSJUeLiGhpCpiZDxJDDoQkgaNaRHTO3YbWFhXNhaHvi/EHcY5z1AkeZb2VKnQlMA7w==
X-Received: by 2002:a63:cb4b:: with SMTP id m11mr35668140pgi.49.1564501200236;
        Tue, 30 Jul 2019 08:40:00 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id 195sm108148638pfu.75.2019.07.30.08.39.58
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jul 2019 08:39:59 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	arnd@arndb.de
Cc: ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	hch@lst.de,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [Linux-kernel-mentees][PATCH v4 0/1] get_user_pages changes 
Date: Tue, 30 Jul 2019 21:09:29 +0530
Message-Id: <1564501170-6830-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In this 4th version of the patch series, I have compressed the patches
of the v2 patch series into one patch. This was suggested by Christoph Hellwig.
The suggestion was to remove the pte_lookup functions and use the 
get_user_pages* functions directly instead of the pte_lookup functions.

There is nothing different in this series compared to the previous
series, It essentially compresses the 3 patches of the original series
into one patch.

Bharath Vedartham (1):
  sgi-gru: Remove *pte_lookup functions

 drivers/misc/sgi-gru/grufault.c | 112 +++++++++-------------------------------
 1 file changed, 24 insertions(+), 88 deletions(-)

-- 
2.7.4

