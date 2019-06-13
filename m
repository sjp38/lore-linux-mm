Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E79EAC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:59:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F16205F4
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:59:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F16205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 258066B000D; Thu, 13 Jun 2019 00:59:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 209356B000E; Thu, 13 Jun 2019 00:59:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F7EB6B0010; Thu, 13 Jun 2019 00:59:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA2736B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:59:24 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s4so8169136pgr.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:59:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=/7WDCBC5qFx+f/Kahslw5ORYJBb3fYU7g6V0PD2h25w=;
        b=QEk4Z3pyrIjvpHJoY5/6xYrGWC/2Zmf6h6Y/L7jmVyzN+PtNVdsqhojNwFN4oH0C+u
         5mTIhVKRVSn2duiPi2FPBaOUH71ikLDvbOqybj8/yyqZuwJMurN/iduhkQGkoGzK92q2
         NJTvuBhSWL/AP6lghI/tlnsgE4nBS1BTskbDDDbcQIPmBvWJkDgCuk97Y6g7WnN+9ZFr
         6zPTyn1XmAJuIvVhfgG0JB1iTclTgMs07PJwpw5YdV8UGI3z7W8PMu9y9XYV0T+ASJxD
         hRbagKufYaHVsXWCFsR0BEzr5EmoyNumc/xor+lFGnHyHbQcFOztYoJN8z8In7FqEPpP
         QmFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;       dmarc=fail (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUWJfAmgs00OpZ4kXYtXCzY2K6KShJrfzouhsLjOyUKUPOd/j0G
	yqaRfcNPeOhFeudjlBkx0o103oYIhfDVDzKX7MSwYVrzJdM1EGsiCXQY1/mKC8XzBw6i35mmL+F
	6aPQ/AKJVAQwvSx6Lg7XQPqwVpsj8cv/TJjiHRCHZ7nI7uaWdo6E+6KbVT5AWrvw=
X-Received: by 2002:aa7:9786:: with SMTP id o6mr4335083pfp.222.1560401964416;
        Wed, 12 Jun 2019 21:59:24 -0700 (PDT)
X-Received: by 2002:aa7:9786:: with SMTP id o6mr4335000pfp.222.1560401963606;
        Wed, 12 Jun 2019 21:59:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560401963; cv=none;
        d=google.com; s=arc-20160816;
        b=Dj8GEMdkdn9Xs4QNXqZJp0AdYRC2cFn0wOTmYJOa+PPiVjdvhD6qT6rCnPMk4xtHkK
         qqk9DFdiJR48Z+CPr++1qcR/imCRSk6piWFA92KY6hn20AgjivdGfL+dXxv/Fcvofp7T
         1TrvAeqaGnO2haeAk7ojuilYKWL6wCWmjlZesiOJ91uCgsFYJ57qINbKKJLfW6/tPPqX
         em7rqpZVVnP62OYSqdGL9Hu4gxY9PxCexfIxW6z54TfT5fImow3mprwbAUn9kvWcLmPV
         RhjXTKL7EH1XE6DMwPvlaYJR2EFU2/ZfnmP+oa8SVgsdP7rqYQXbGPMKu0BcqNaT2Cv1
         R0EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=/7WDCBC5qFx+f/Kahslw5ORYJBb3fYU7g6V0PD2h25w=;
        b=u7pfNFHNEMjJ9LdCynfQcPhgmD3RmojxuxDr6ZQ7U7hSGcntyrLWw0CwtTYvDlhPET
         W32w1+roHNOF1X9T48v04kEXyp/9nHySRJVrSLA8C+ePI9qhAWOa+IkNO5tCfOan8VtY
         e6SRkwXKf19a0KRYiVPAcw6mSC3ORtO8qMqUvPsRoLGEVsBMzU0keFfbCZHNeLFwOYuj
         RlZmFH5z4IZwbEVHi+V2Lsh6Nmijt+Ycy2nw/Rr5D0SJAxjItmVqZBT6hBaduEr138lK
         /1SCqQ6XdwUJxGmaVbIH8HuX0/AMl/8f4G8NNvenD5BvjQR7mMBle4Qm24G2XAGpmQT8
         cS0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=fail (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor1471356pgs.32.2019.06.12.21.59.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 21:59:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=fail (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Google-Smtp-Source: APXvYqynlMwaqsDKPUe5nel7CccY8UDY5gB3/QWR+ZWv7D7rB9qEUOnlWCP1qKidM88aV6+COX4Zqg==
X-Received: by 2002:a63:484d:: with SMTP id x13mr19594551pgk.448.1560401962810;
        Wed, 12 Jun 2019 21:59:22 -0700 (PDT)
Received: from htb-2n-eng-dhcp405.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id o66sm1215327pfb.86.2019.06.12.21.59.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 21:59:21 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Nadav Amit <namit@vmware.com>,
	Borislav Petkov <bp@suse.de>,
	Toshi Kani <toshi.kani@hpe.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 0/3] resource: find_next_iomem_res() improvements
Date: Wed, 12 Jun 2019 21:59:00 -0700
Message-Id: <20190613045903.4922-1-namit@vmware.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Running some microbenchmarks on dax keeps showing find_next_iomem_res()
as a place in which significant amount of time is spent. It appears that
in order to determine the cacheability that is required for the PTE,
lookup_memtype() is called, and this one traverses the resources list in
an inefficient manner. This patch-set tries to improve this situation.

The first patch fixes what appears to be unsafe locking in
find_next_iomem_res().

The second patch improves performance by searching the top level first,
to find a matching range, before going down to the children. The third
patch improves the performance by caching the top level resource of the
last found resource in find_next_iomem_res().

Both of these optimizations are based on the ranges in the top level not
overlapping each other.

Running sysbench on dax (Haswell, pmem emulation, with write_cache
disabled):

  sysbench fileio --file-total-size=3G --file-test-mode=rndwr \
   --file-io-mode=mmap --threads=4 --file-fsync-mode=fdatasync run

Provides the following results:

		events (avg/stddev)
		-------------------
  5.2-rc3:	1247669.0000/16075.39
  +patches:	1293408.5000/7720.69 (+3.5%)

Cc: Borislav Petkov <bp@suse.de>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Ingo Molnar <mingo@kernel.org>

Nadav Amit (3):
  resource: Fix locking in find_next_iomem_res()
  resource: Avoid unnecessary lookups in find_next_iomem_res()
  resource: Introduce resource cache

 kernel/resource.c | 96 ++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 79 insertions(+), 17 deletions(-)

-- 
2.20.1

