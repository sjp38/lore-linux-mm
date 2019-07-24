Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2EB1C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89329229F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oSS6z2pR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89329229F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24CD36B0006; Wed, 24 Jul 2019 07:41:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FD036B0007; Wed, 24 Jul 2019 07:41:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C7A18E0002; Wed, 24 Jul 2019 07:41:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C77366B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:41:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p29so19904516pgm.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:41:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=vUoAw9IYsxFSDNG2uruyjPHm6XhF4oDBz80MmGH0I+c=;
        b=BJfCih8K9zmPfxGPhvKg6dNQCHgKoea0P/jaoQOlzgnnqHtx5EbywIgVTrNGjPzPz9
         y2GqEECawE/YX4L7aA2pCsMGnZuhofpHcpmZ2ckXgykhW3RryOENzmvZzU6/whAb/d9r
         qRq+lgbyzA9LJuA87A8HTyrqPQP/3scaO/OzndeJTB4Mxatc3ujqP2okcB+azVEKyCFp
         5Var6KVXUnUgIDvwn7qfX3d4CJbxQRMAsZmEPquBx1B6hAZ3BB/iApzojwQL9Xyfc+EU
         t+EVYWjKXU+MOFXjAqspxdYytt3bfzfdgOF+BNkxI/L21HcEB3tr/rlpDd3TLgXJx4sA
         F/Tg==
X-Gm-Message-State: APjAAAWW7E4qd31jzo47eVgdoFdEFRN8zc5PbjpWYOKzo7sp8Si6YzFH
	nyOyAHl+Betrg7Qy5y8Gu9tdM6ga8cKaomOasSP66gZxHvYnEeunflj5iI+ELYEoPcah7XAWNXw
	JfH9rX32pqu8V/6Cp+UW4t7xomstcuyhUpvJsfeH8MiYiYiYFeupKroeuzMGxlAgSIQ==
X-Received: by 2002:a17:902:9f8e:: with SMTP id g14mr39550736plq.67.1563968491351;
        Wed, 24 Jul 2019 04:41:31 -0700 (PDT)
X-Received: by 2002:a17:902:9f8e:: with SMTP id g14mr39550661plq.67.1563968490546;
        Wed, 24 Jul 2019 04:41:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563968490; cv=none;
        d=google.com; s=arc-20160816;
        b=FexVB24nhXgdRlP3B67VOJBGoiYhVaSznq6dYQsQRSnOdCq7eS+RZxgNOY4zYIj1q7
         6mJGSezMrDgsp8y5xFLVL/Sm5vuX/+VDOaeOkIYrtMe+pY10t9Sb62eDeOMpk0WL6eKQ
         2khG4Fl6stClp7ktx+7BC/cly1YsD0tHOd/37w33+pH97Yd1IP/fDBzhMnQqB05lAdBG
         dQBXZN1Svw99hJAhQb9dr4MC5yPaBWvX5A3ojAWIvfDiNViHu/19BqcQ3ZeRkKYyE1p9
         QOaLRSOONNwFVbVczYF6cik2xbV/9q5u36Lv+qi+3VODSvww/mxCm0/2KmRyFG4mbeJm
         PlFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=vUoAw9IYsxFSDNG2uruyjPHm6XhF4oDBz80MmGH0I+c=;
        b=fAczVn71qGFmF9UhfSJ7eiBPzxp1F2lL3x9JtRCi6s9Qe+vocWsCRdnnaMqkVFDxAK
         AqG3O0tqVoqEn/Qni+e0E3jlUFNbpwzi9rez8DYKFHsr1fXDM+GoZBT75GLzGY9iB66r
         ipQ3OIdxCatM7+hM2JGGqfO0KVhCD9oE6FXQ420Ma3jgKtiojyZ4NyJt1BmvCs3rXDrP
         t3zw9b1dHUKoIKRIQZFnwOKoQoKINEbqbXgF/Xqg2w/FQd08mvYffOcMrhzesZ4ryins
         QcXFdV1bbxCcEQfgf6P/vqm3xUx+0XFrTd7QTV/UcaKRuqRdntxpyp5WsZoSxjQgu9Eo
         fpXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oSS6z2pR;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor54852216pjz.4.2019.07.24.04.41.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 04:41:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oSS6z2pR;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=vUoAw9IYsxFSDNG2uruyjPHm6XhF4oDBz80MmGH0I+c=;
        b=oSS6z2pRqF5Ym3nqGS3x+om5IJIatfw2MYM+Z4wz63R3A3pKCb0+cfpjjn/S08EJ+G
         9ZFkJiQucJ9voR50uVSL4HUbiM23BPgL4Sa8cqixGTdIcMpDAaFl2ytXRhr9ESTcSb3E
         lcpb+5CxerBqXenXrR943zrp6J2vC8YhUaRIKZ9BQBHtYluJNxAMvZNprsmVbS//gWLo
         jGsOOuCEcTfkmbecwN3ADDjh3hsxW1OaQ3mCiwYeOSZS8aYII/POfoSnAUMep1H/h0h6
         THFPzi6BwrNaiK767akFUdWhBqT/6O1mDoT7T0U6Hxrrk+7qc5uQoSsx0DYyG6QQKJ2i
         /kUw==
X-Google-Smtp-Source: APXvYqxfrWQEe5JThmMch91J5yQRowYBVSY6S4IZZQAYyTJ6Dy1JLZ0Er7W6o+H7JETocCb0dOJkqQ==
X-Received: by 2002:a17:90a:8c92:: with SMTP id b18mr85654749pjo.97.1563968490088;
        Wed, 24 Jul 2019 04:41:30 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id a16sm49348659pfd.68.2019.07.24.04.41.28
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Jul 2019 04:41:29 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	arnd@arndb.de,
	jhubbard@nvidia.com
Cc: ira.weiny@intel.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH v2 0/3] sgi-gru: get_user_page changes
Date: Wed, 24 Jul 2019 17:11:13 +0530
Message-Id: <1563968476-12785-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is version 2 of the patch series with a few non-functional changes.
Changes are described in the individual changelog.

This patch series incorporates a few changes in the get_user_page usage
of sgi-gru.

The main change is the first patch, which is a trivial one line change to
convert put_page to put_user_page to enable tracking of get_user_pages.

The second patch removes an uneccessary ifdef of CONFIG_HUGETLB.

The third patch adds __get_user_pages_fast in atomic_pte_lookup to retrive
a physical user page in an atomic context instead of manually walking up
the page tables like the current code does. This patch should be subject to
more review from the gup people.

drivers/misc/sgi-gru/* builds after this patch series. But I do not have the
hardware to verify these changes.

The first patch implements gup tracking in the current code. This is to be tested
as to check whether gup tracking works properly. Currently, in the upstream kernels
put_user_page simply calls put_page. But that is to change in the future.
Any suggestions as to how to test this code?

The implementation of gup tracking is in:
https://github.com/johnhubbard/linux/tree/gup_dma_core

We could test it by applying the first patch to the above tree and test it.

More details are in the individual changelogs.
Bharath Vedartham (3):
  sgi-gru: Convert put_page() to get_user_page*()
  sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
  sgi-gru: Use __get_user_pages_fast in atomic_pte_lookup

 drivers/misc/sgi-gru/grufault.c | 73 ++++++++++++++---------------------------
 1 file changed, 24 insertions(+), 49 deletions(-)

-- 
2.7.4

