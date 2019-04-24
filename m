Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A830C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2E2C2084F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2E2C2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60DC96B0005; Wed, 24 Apr 2019 07:12:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 598CB6B0006; Wed, 24 Apr 2019 07:12:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4374C6B0007; Wed, 24 Apr 2019 07:12:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 049496B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:12:23 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id x18so2632650wmj.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:12:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=kmzCr1i6Yo0dpWCYiXFB7RxFx1oPWVFnMeS8/WAGETI=;
        b=mAwoH8sG+k8Lx0Byl441cDsojFnzdnJ0zDKYzbT1qidnYKhIFHzxlTy5pfBfHLHv4S
         wYh4DaLJOcjN+T2GppBtDNUwT6/jVwTIxCKImwMsbtDQS6gV0vXAFFal4Hdoi3XlqTSk
         5SwWxguZxqG+lZpg8D1AKIaTDmjgIemewH0MNtHmwW+rhB9F6qIUU1PBmXpoYAwKv7GR
         qvymdCW5Z5DPKdRo1VR92J8d69BTN8BuZFGnbpGM/IcD2609+oS8tRRRjWwKcsIwGs9K
         qTt66S5vv7dXURw+XmyA7+4AUP8TrVF1NoYABcgNg4t/FXNEUh30ljfbCukA1ROECfQn
         /ixA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAXo2Ns4O1Xxkre2JQI68TAsEVSncPdAzX9uQHGdlH9VJAJGXX0M
	nuViXVVmau3Tgv8GGcKQ7FaJrCYCLm0WOKSusv04jdJUGrCj2Gg9d9H29GAGi34/O7ZptczuCZ/
	kbdxDMD2/KoOK9VzTgLQGOrx+Ev8h1Dm34VSRhpb7ppn9limys0mgHaie59XN87ehXw==
X-Received: by 2002:adf:9427:: with SMTP id 36mr4702284wrq.128.1556104342538;
        Wed, 24 Apr 2019 04:12:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPnLsinS3CiQic0++oc5k53wMW7kMlAgdAkfzZoW1jbpwxbyqXf1E2UIDDy2EM5te0Fvqs
X-Received: by 2002:adf:9427:: with SMTP id 36mr4702217wrq.128.1556104341600;
        Wed, 24 Apr 2019 04:12:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556104341; cv=none;
        d=google.com; s=arc-20160816;
        b=lA4knrVYzRyZ4lvi56IQo8oE9+0jBW/P5P7beZ/7RNVu05uRx3pcQeIAqyzocxoyn8
         1TPEHjoqwkxRqFARQUZRdnD9iRh2DxzoxIL6tRbniK0GlkuZY2fGEaX0BGSYyKn4XIDN
         tOwRz/5wcZC4qZ6//C3yQOFTvzfYBndjk8m9/96G/L4UQIo6aeIAedvKJQ5tYEtD6mkg
         h9UDjwGHYuPFhHBT8hlSybuXFKeD2TnJZIuqC2LNW/NoUXpbXUoJ5ZoSC3gha4PL0DiK
         rthLepZNH5qPajFi13qCACaZvHQEPNfFqFv53SuVjo1AJjPiHHUdltDYPxqmt8lYwbu1
         HbzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=kmzCr1i6Yo0dpWCYiXFB7RxFx1oPWVFnMeS8/WAGETI=;
        b=h2VFDpiAQqcVUkAUqSAz5dQVJkGncnVLrg3s/r7tb+i6vkBNTxFD1heQzka7GEGqcv
         bg3/JppOQonsD1zcTH2q/zGNZ8fEgwKOq7LRfI+IWBRPwD4UtaNKZB1PQDLUntrtiIBI
         l49zojhl7TWOXRXxyI/S62R27vZd/bnTzZjPk6GkUPGkjtgVk0trgNNlAKtycAl/rEb7
         oAQozH8VSYbJqGxRaw2mfT1PBQV+kdu35Y6PBETRbOYPB3BTH2QNncbAL/BKYwHWI4mU
         PiC0XjgOquSh7f+yCPKetaKqu6kCxOt3d4HdoQpGn3dThM6uDJiq9lBhYQrPhgOW7Z7e
         VruA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m18si13821550wrj.311.2019.04.24.04.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 04:12:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from localhost ([127.0.0.1] helo=flow.W.breakpoint.cc)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hJFp5-0006KY-Qb; Wed, 24 Apr 2019 13:12:19 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de,
	frederic@kernel.org,
	Christoph Lameter <cl@linux.com>,
	anna-maria@linutronix.de
Subject: [PATCH 0/4 v2] mm/swap: Add locking for pagevec
Date: Wed, 24 Apr 2019 13:12:04 +0200
Message-Id: <20190424111208.24459-1-bigeasy@linutronix.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


The swap code synchronizes its access to the (four) pagevec struct
(which is allocated per-CPU) by disabling preemption. This works and the
one struct needs to be accessed from interrupt context is protected by
disabling interrupts. This was manually audited and there is no lockdep
coverage for this.
There is one case where the per-CPU of a remote CPU needs to be accessed
and this is solved by started a worker on the remote CPU and waiting for
it to finish.

In v1 [0] it was attempted to add per-CPU spinlocks for the access to
struct. This would add lockdep coverage and access from a remote CPU so
the worker wouldn't be required.
It was argued about the cost of the uncontended spin_lock() and that the
benefit of avoiding the per-CPU worker to be rare because it is hardly
used.
A static key has been suggested which enables the per-CPU locking under
certain circumstances like in the NOHZ_FULL case and is implemented as
part of this series.

Sebastian

