Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A453CC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:38:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6591D214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:38:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SAyePnvx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6591D214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E95036B0005; Fri,  9 Aug 2019 15:38:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E45956B0010; Fri,  9 Aug 2019 15:38:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5C066B0266; Fri,  9 Aug 2019 15:38:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A06F96B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 15:38:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id m2so8972787pll.18
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 12:38:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=s0jRl4f3hMFvY797VTlUgGgaEZaYTvYyYtEs42v09cM=;
        b=K2gk3WUtT1eVA4UrPkJMpVX5nvpGjaeGAS8wxtikOXaclFCWBng6lOSbP+nwFSMKxp
         i7R2XAARJfJpp6iPAJzclGaA3AnCIz3PWlgkxmuSQp1HTMsL6W4nj3bXKNHMbMzHu2ii
         Sva7fStGLN5+aGmyua88gCxzY+3iyLQJxD5YaT6J94fQPSx4/5QXGXVwustfFxZH32t+
         1KqHaCjPcPinEVzurob669F5OYyJa1RQTN+FaTZe9knAec3BuO5hiM4yv+n7xcgbaEu6
         dfsX37bLGkmI7iRnd3lOTql20dNcOL8s8nNbBwRndSxc3Vcw0kMKVjXqfZhZOK4mHjeq
         dJAA==
X-Gm-Message-State: APjAAAWkPUB2paJlijN/ZhZ+VYIUx+qlE6uchpRhlB4da5bae2o5Et+Q
	QDgd4XNm/KYTt2wSmnMWCxNfV/ZtlZjOdeZxvJnqb/e9HNyUjWJdY4iz+DV+h85DJbt1XT0E/hd
	8BGrorEuL2awvUGH0unNbxvZ+SVOjrz5MAR/tNu5IIbFQeamdWV+KuonvKNx0A86Qdw==
X-Received: by 2002:a62:e815:: with SMTP id c21mr23983255pfi.244.1565379525254;
        Fri, 09 Aug 2019 12:38:45 -0700 (PDT)
X-Received: by 2002:a62:e815:: with SMTP id c21mr23983219pfi.244.1565379524597;
        Fri, 09 Aug 2019 12:38:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565379524; cv=none;
        d=google.com; s=arc-20160816;
        b=SBzeCKeswFpBgQ6kNcP4IIcJpb4EJKaJBW/0xsn4FcLlx8anT9PbQ+4f0K8dj6Rg99
         za81Ya0TvmMikLeyUX43o+puRHW2GvgUu574QAbsAUzCTxDm54Wr0NWQ8qIRm0auUwbe
         /O4qieeuyiS+aj5OS412PW3slfRaoybHVyEABD/60oX3GbuOqjkSkY/AG2j8BWiS4WCP
         fC2XeLMl6LlFLFxF0faY3tiQI++dEPHSFwJPVFtEP3Q7BrtiRPy9qJWYXonEnW90Vspn
         T8P4QTxDJemJQ5U8hqYwr8LC8lzHV2dG2J07R0DIuP97zGW1jA/FZ/lcwcDOUGd7nA9R
         ZYcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=s0jRl4f3hMFvY797VTlUgGgaEZaYTvYyYtEs42v09cM=;
        b=bZd6tLdF9uxrCux1PINdwP7brSiHiAK2p9WscRD177D26zRhVTRc39kaeANME4luGt
         +YwU52cm1JG/xOuW6N+iUN3n7oQip/qD8yhuwX6vlyctEoNQd5NRUNHkElaPAlFPVzkS
         dNV4Rrr9MvHvarhorptLfDYI4zBC9/mi3s7QSmRgdBA1NCiwmsbjGHD8WIVByz9e90YW
         eJU+I9yACNrCIYjg2VQbH+29hgl/iSCmnigPSWqm27v+3NVfuflWtc2sEbUMCPZnasNQ
         snRuKwNV5Z4QGPHIq7KTia53wJ7OVu6oWjez2dFSRK3w7Kn2GoF66/hxAEJ0RUjePiUV
         hgbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SAyePnvx;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor116746244plt.10.2019.08.09.12.38.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 12:38:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SAyePnvx;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=s0jRl4f3hMFvY797VTlUgGgaEZaYTvYyYtEs42v09cM=;
        b=SAyePnvxQx0JTb8PX8WhY8QrOVPChnu5XgHnchPD4uybMDVy0AJkPuretmKny9wovt
         u3uRQU4D+fTOiRjhiWBDzMfstVe4RWOa76oeblYvur1rqCMDa5c485KjmHkyvdILpcAU
         OnIsyR7JA97sd3zqjy6XkejM2p4DYoWckjKjzQhbr1OS1c7f77EBclVMJ7tUSlbaXXNU
         drClDLIyM3UbCMsShQqNqJfeCNQdplGDeMWiUFV8CWhjV7J3U7fBlIZ5e+3W9EV7wK5f
         GyCk+jSlMipL/XhmsrmXsR5Xbi7w3hiNv1m7JNCWw73t4r3+BxtRrtkpKAyAP7VI9n3v
         +53Q==
X-Google-Smtp-Source: APXvYqzO8KILPyoEvux0/VJWFC86QLoigsWPvQAwfoIB57aBVV81Lvh5KqInxVfA+F4pYN1ysD1Ctw==
X-Received: by 2002:a17:902:e30d:: with SMTP id cg13mr20603895plb.173.1565379524284;
        Fri, 09 Aug 2019 12:38:44 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([2401:4900:277d:9fe5:c098:ab6c:e50:f58c])
        by smtp.gmail.com with ESMTPSA id k25sm83790965pgt.53.2019.08.09.12.38.43
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Aug 2019 12:38:43 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: jhubbard@nvidia.com,
	gregkh@linuxfoundation.org,
	sivanich@sgi.com,
	arnd@arndb.de
Cc: ira.weiny@intel.com,
	jglisse@redhat.com,
	william.kucharski@oracle.com,
	hch@lst.de,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [Linux-kernel-mentees][PATCH v5 0/1] get_user_pages changes 
Date: Sat, 10 Aug 2019 01:08:16 +0530
Message-Id: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In this 5th version of the patch series, I have compressed the patches
of the v2 patch series into one patch. This was suggested by Christoph Hellwig.
The suggestion was to remove the pte_lookup functions and use the 
get_user_pages* functions directly instead of the pte_lookup functions.

There is nothing different in this series compared to the v2
series, It essentially compresses the 3 patches of the original series
into one patch.

This series survives a compile test.

Bharath Vedartham (1):
  sgi-gru: Remove *pte_lookup functions

 drivers/misc/sgi-gru/grufault.c | 112 +++++++++-------------------------------
 1 file changed, 24 insertions(+), 88 deletions(-)

-- 
2.7.4

