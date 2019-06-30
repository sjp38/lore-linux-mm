Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A70BC5B57E
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E3BC208E3
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MDOAghVf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E3BC208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 050DB6B0003; Sun, 30 Jun 2019 03:57:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 000538E0003; Sun, 30 Jun 2019 03:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE3308E0002; Sun, 30 Jun 2019 03:57:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f208.google.com (mail-pf1-f208.google.com [209.85.210.208])
	by kanga.kvack.org (Postfix) with ESMTP id A5FCC6B0003
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 03:57:22 -0400 (EDT)
Received: by mail-pf1-f208.google.com with SMTP id u21so6704276pfn.15
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 00:57:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Zot35M/uaWueI3Zn11kPJ6IoYKlYtkLl9I4J6OvDMjU=;
        b=ueo9ibWzFvr7e9dF+bF1B+QGmvGN/2YUc+btDgm9bjwZBSY/+NO6Hmi4lmu4JLSqNK
         vbFWXTICyGY7e+iJElMuqX03fIEiEhjKR/+G1+Fg4nbHvi+aHjcWgoc+VUMIPZEp/tRt
         rVnNfFNM7BhIRvedJ6+Iew7vctoLEWfIW4DPLdoB5RkLkyammjE4gGc+4mz/5cmsgHmL
         32fVpfeKMCY8QywLhjbOX/0fYA8CAWzAL1WpNdVtFDBsofY5XQ3Ha2u/neLsv/VcSrqq
         ex6ihjk8dnH9yubLRSrryv6So1bc7Px6KXE1503QjE31wSKTc1HPYc0LOM9Pac4eYLAD
         JEKg==
X-Gm-Message-State: APjAAAX7yVDb9zWa2ntKnDhbOPyogtsXfsaKuB8NFtDTIPe6EnfKJJFd
	hK+lzSpnWvx4HfnBIkNFEzbJsJam7SNvysDyLRKaS+HYJlNuZ30qnLE+NjliZRhwRJ2JtzJ+0uL
	bt92eg/QrlzcbYEj+Qx88L8OQaFU5oVYN0qidAJFV48peI00fnEmPPr5ZiYJyhf+WQQ==
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr23788025pje.77.1561881442182;
        Sun, 30 Jun 2019 00:57:22 -0700 (PDT)
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr23787949pje.77.1561881440304;
        Sun, 30 Jun 2019 00:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561881440; cv=none;
        d=google.com; s=arc-20160816;
        b=jkpI66F15DU7A6mwcQQzmJcY475VRXIeLersx7UPt4o+6t3WEWQzX5jrxYCC8wKYm0
         wRQaIFamTJwllt2emgZtypzDuW9rP108p3OprS2oqQSIhaRniWLG4Al1dTJcElFL+G4F
         Gg2Qpq9CEU9A8QskfbrOexREGsr9Cv0Urh6HydOpEQ6Pjdqn2YRB2rXuGAfPHa3+qFW5
         9WHHFjz3PcHdGj6YrPVz7Gui7XRQmKKWkWSUQy7pz2glpJBFtGLSjaBDC61S65HaPHzD
         5wN7bHJT+/ZxWUJ6gFcUv0yYcCLxLzCtuworpy9QtRfpyLOKBhWjeqD50ITOo4adRnfn
         If8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Zot35M/uaWueI3Zn11kPJ6IoYKlYtkLl9I4J6OvDMjU=;
        b=OmW1Lw4+Ny+53iiovhbjz/z86ulZTtHEKu0W5QskAomzfIRDtUPgvnZhVWUcWGGqBS
         MpIXf3m1CozfBCHBG+2yne2ClxxBFIK4L8tm38wzt6R1BwJoyfvilZoaJGtWXvkC15Pz
         ppJQAoIghrUBX1NGTKh5butpfibgtFbxSsowl0f8LtLaLT6pWPXSXg8sERUZLhz1aQiw
         90yDA0GmV3v0lcPpEz7ZKUdkStcU+6bepZ1HK09QUItFGK6imK2eu8/A8w67fv0IFQIs
         /WWeSl85Tr8xaajKjrqbtaFFeTygJYZ5ncYb7aRuWstYYkaBUyY5UXceQCgSISOR/IDv
         X+nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MDOAghVf;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor3052295pgo.60.2019.06.30.00.57.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 00:57:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MDOAghVf;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Zot35M/uaWueI3Zn11kPJ6IoYKlYtkLl9I4J6OvDMjU=;
        b=MDOAghVfP0e9bM/YbPeMmPhQMwo21Fzh3ULYKrYMmY51cSPsMd0TKeTq2mz0MMAQqh
         2FxILl8UP4nlrKoUX1a2KqBTRUVC21XguujryIxOEmbrKUhiJXlZuDumw8UMmP/Wy6zf
         X56oMJ4bEzANTKRWLKZs6gUUMFh00IBTpWHmvmMUTR5NuL/45yh9AjzHHMyvI1qi28bg
         jPvu93egb0PNGacqq0d7lfCrRJC1N9HDSYGv6k81Jjnwt/eRYqe1rRMAA9mokS7ubI2H
         9xT3VZtB9lXk8hW8a1r9Mk2+yYBTBNwiJGntmIKAc8fEtazTjLIxl2CT2Y6oAGt4g6GF
         ElLw==
X-Google-Smtp-Source: APXvYqycBX9TRWgleMymlOn1K6bwXz8ht5R8eZXbow/n8eSDdBMe0GA1g+zblHybHoTG7dMX1EbwYw==
X-Received: by 2002:a65:4085:: with SMTP id t5mr18419154pgp.109.1561881439844;
        Sun, 30 Jun 2019 00:57:19 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id w10sm5989637pgs.32.2019.06.30.00.57.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 00:57:19 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 0/5] mm/vmalloc.c: improve readability and rewrite vmap_area
Date: Sun, 30 Jun 2019 15:56:45 +0800
Message-Id: <20190630075650.8516-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This series of patches is to reduce the size of struct vmap_area.

Since the members of struct vmap_area are not being used at the same time,
it is possible to reduce its size by placing several members that are not
used at the same time in a union.

The first 4 patches did some preparatory work for this and improved
readability.

The fifth patch is the main patch, it did the work of rewriting vmap_area.

More details can be obtained from the commit message.

Thanks,

Pengfei

Pengfei Li (5):
  mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
  mm/vmalloc.c: Introduce a wrapper function of
    insert_vmap_area_augment()
  mm/vmalloc.c: Rename function __find_vmap_area() for readability
  mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
  mm/vmalloc.c: Rewrite struct vmap_area to reduce its size

 include/linux/vmalloc.h |  28 +++++---
 mm/vmalloc.c            | 144 +++++++++++++++++++++++++++-------------
 2 files changed, 117 insertions(+), 55 deletions(-)

-- 
2.21.0

