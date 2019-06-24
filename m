Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31513C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:48:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCD432089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:48:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCD432089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A8FE6B0003; Mon, 24 Jun 2019 03:48:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 530D48E0005; Mon, 24 Jun 2019 03:48:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F82A8E0001; Mon, 24 Jun 2019 03:48:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08D466B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 03:48:31 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so6894177pla.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:48:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=EYvr4pbjUvpabCRQjJVCkjiyZpzbjdxLKXFCYQOLKTs=;
        b=rD3JDDmCkc/lyU95IBIfx2m9tnVXK+gaIvoSTzlBiPaVteIaXCzRa/WJlQzeXsdUMU
         1upoCngbeShVls8c1E0TloQ05F7wHIt8IEgONG59Ox5kbPbkNMmWsZKTech7lXb0ufBw
         n3ecyQZlCMoTzhYievCqOhN2/pnU158EVb1TSHqPVLQQa05OB6cml/+IivYuxYFUyqcM
         zbZD4nRdlRtPER19qx2PFsi6MDjMsfvxrm8kPkIcy7F4zl92YNPnyyLWZUfGeJuoyEH7
         KLETG9anc6GnqsFqGuHtghtVHhWyVTntJpgdX4lEYJfHXOtWR4vMF4/E6LAyIyFcWDMF
         DKjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAWN2aLjztiAr+OReIADKdXBW4zeernJ/kcmeebNSd9PNKvJxilV
	IHAEbLuDBQnwCBL3KbEvzmkw9+MlaFC6q6HO5pRvrtYbeg+MPUOIH2iy84RQa7D1qpDYzfITAzV
	XHfcLE7L1urAFr4qf/ORn3qDEfN96WjOLuV/k/qgnqMazHd5PavzycI1MOFVQ9vQSwg==
X-Received: by 2002:a17:90a:9289:: with SMTP id n9mr23416872pjo.35.1561362510702;
        Mon, 24 Jun 2019 00:48:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOW22t6ztXlfmDPPXJRbjTZQ+rU0cr68YZPgdu3pxINm3QUxW0lF1jhlRRDtqTni/ZYx2r
X-Received: by 2002:a17:90a:9289:: with SMTP id n9mr23416818pjo.35.1561362509892;
        Mon, 24 Jun 2019 00:48:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561362509; cv=none;
        d=google.com; s=arc-20160816;
        b=PidtU+aJoS7TxT24SbRaXazjgmHwVyOZZCs623d/UC2wBn5gurhm3XBiAOYoiSqsxp
         U6xjVTbPBcUQIVCYBcjzq0TjnOD3eCAL3nk4+YJvDOYpy/SDtI8fIN6YRXscPE2VGy9S
         it6qr80m3pghMfkWprYN1juPFXZqUHkch3z5AFHMEyNnOh9+VqwjWOIdToj3UIHPSy9e
         dek/zoc/VJqI8PPAKvo3WJEieS+5LVNK0N4GDGI8U4CfQ/B/W2vP0jYax9epb7B13jnn
         mYdDa4XoXBluue4Po2B5f/rvjHzS9fuKL25DVFJoLpLm4Fd4KYnSpZrGEkiDeBVn0UnT
         j/NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=EYvr4pbjUvpabCRQjJVCkjiyZpzbjdxLKXFCYQOLKTs=;
        b=E2q5VcWS1do6tfM/souZ94yDe41XbCXFUyYL90PZeMWLC2wAZIjdWXX1p4zms5fhqD
         YppdLeR/hJyaD1sPM44JU+YRLmUjBBwU60qiFfHPBWXimtFbv9t22pJnyqye9/3yj0xY
         hF4u9DJgdTD8nfRLwROFrrAYbLwlhbpV4NqHSNa425LusbSztKaFFlU69Z0mOiZ8jaKq
         SV1iM3PgYrVkzcUGDVpk8a1XRC0cHrsN6B3ImM18tOr+Xeyf8yWVkeFqkeVMoaL15asR
         CPxAitGm+ovOraOMZypwCp8nE3X4PuTVXRG2u+y7hTW1mWhpyhD5SucS2ogkOzEN017o
         p7Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-166.sinamail.sina.com.cn (mail3-166.sinamail.sina.com.cn. [202.108.3.166])
        by mx.google.com with SMTP id d39si9659519pla.371.2019.06.24.00.48.28
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 00:48:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) client-ip=202.108.3.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.4.32])
	by sina.com with ESMTP
	id 5D108049000053AD; Mon, 24 Jun 2019 15:48:27 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 799535398541
From: Hillf Danton <hdanton@sina.com>
To: Song Liu <songliubraving@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)FS
Date: Mon, 24 Jun 2019 15:48:16 +0800
Message-Id: <20190624074816.10992-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)FS
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello

On Mon, 24 Jun 2019 12:28:32 +0800 Song Liu wrote:
>
>Hi Hillf,
>
>> On Jun 23, 2019, at 8:16 PM, Hillf Danton <hdanton@sina.com> wrote:
>>
>>
>> Hello
>>
>> On Sun, 23 Jun 2019 13:48:47 +0800 Song Liu wrote:
>>> This patch is (hopefully) the first step to enable THP for non-shmem
>>> filesystems.
>>>
>>> This patch enables an application to put part of its text sections to THP
>>> via madvise, for example:
>>>
>>>    madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
>>>
>>> We tried to reuse the logic for THP on tmpfs.
>>>
>>> Currently, write is not supported for non-shmem THP. khugepaged will only
>>> process vma with VM_DENYWRITE. The next patch will handle writes, which
>>> would only happen when the vma with VM_DENYWRITE is unmapped.
>>>
>>> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
>>> feature.
>>>
>>> Acked-by: Rik van Riel <riel@surriel.com>
>>> Signed-off-by: Song Liu <songliubraving@fb.com>
>>> ---
>>> mm/Kconfig      | 11 ++++++
>>> mm/filemap.c    |  4 +--
>>> mm/khugepaged.c | 90 ++++++++++++++++++++++++++++++++++++++++---------
>>> mm/rmap.c       | 12 ++++---
>>> 4 files changed, 96 insertions(+), 21 deletions(-)
>>>
>>> diff --git a/mm/Kconfig b/mm/Kconfig
>>> index f0c76ba47695..0a8fd589406d 100644
>>> --- a/mm/Kconfig
>>> +++ b/mm/Kconfig
>>> @@ -762,6 +762,17 @@ config GUP_BENCHMARK
>>>
>>> 	  See tools/testing/selftests/vm/gup_benchmark.c
>>>
>>> +config READ_ONLY_THP_FOR_FS
>>> +	bool "Read-only THP for filesystems (EXPERIMENTAL)"
>>> +	depends on TRANSPARENT_HUGE_PAGECACHE && SHMEM
>>> +
>> The ext4 mentioned in the cover letter, along with the subject line of
>> this patch, suggests the scissoring of SHMEM.
>
>We reuse khugepaged code for SHMEM, so the dependency does exist.
>
On the other hand I see collapse_file() and khugepaged_scan_file(), and
wonder if ext4 files can be handled by the new functions. If yes, we can
drop that dependency in the game of RO thp to make ext4 be ext4, and
shmem be shmem, as they are.

Hillf

