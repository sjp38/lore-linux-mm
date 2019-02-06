Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85433C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 07:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C9D42175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 07:24:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C9D42175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B74D38E00AE; Wed,  6 Feb 2019 02:24:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B22C88E00AB; Wed,  6 Feb 2019 02:24:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A11EC8E00AE; Wed,  6 Feb 2019 02:24:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 686D18E00AB
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 02:24:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id q20so4309113pls.4
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 23:24:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=yJXaiUYe2SGfZZwuQ9hGJskgqbJWee3wyulwiBKm5Lo=;
        b=KTd/2smVQTVeIuGEFiVNGH1AlYfxke26NxZmKh3+zoaIG8jShhNzBIAIWpUGB32Ouw
         tp9s+ClTlK5L2SJuRTKCrC944bHAHSDUweGm6LJfGo7JFydy0ZActfjMicgeM3mfkN4E
         0gWmVQ3sKcwaZvd2y6+OIJtUJ/5h4VEURddxlpaHQnTozeH1u7QXqE5Wj86HEoeSN8PI
         tdHdZkbKhDLBcYCGh62I6QTroJCgWbH5406Kl5fHZzpqB/h3rOA+c9jmwuVTICvoaM4v
         YjVmLvrPAKqBjPy0z27BQeGEQX3vKflOm1yqYcr7QsQxFiHlOOfSle/ksatXNc0WGf+E
         X3Hg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZhGoFw66LiL12kWDXQQAIqnabLdmHmJzY0dEhe/L5pnTs01JKf
	OKA/74DEdB6ooeBTWomvbhHhfVeVq/AFuEbhp6LqiCMi0y8ljmow9gMlCzAQu4j7/AAKKSiD6s2
	bbKKAmnNbVHUfA9rdUQZ3VBic1H8Ot105rdjXX0lgEqKzn9Hubd3+W8nF+vtrR+9DTA==
X-Received: by 2002:a62:c583:: with SMTP id j125mr9212627pfg.37.1549437884082;
        Tue, 05 Feb 2019 23:24:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY3qUkUCVICul4FKFTc22hEueV4qS+fOb+ZbqjKkm4V2MwM0P6Q9MVATVNIHRfnZRBVcCQu
X-Received: by 2002:a62:c583:: with SMTP id j125mr9212593pfg.37.1549437883330;
        Tue, 05 Feb 2019 23:24:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549437883; cv=none;
        d=google.com; s=arc-20160816;
        b=d9xz9Yu/RMecLXCl/8/O3LWYzNtuT8qjDKQAxHFLwqraoDAO1fO1o61VUqqZGhphEZ
         oLPbeusRUnV18Ks3T9sQqkp5jdokTQRdiDGcubcfTyx6EFjG9Q/oJRvpiF6qn15n/9u8
         d7GiIabl6foArzqxSFh9GvgCFeia83VcyirCRzxIQUKgaWURwfSm9xKvOmziiJflgVSk
         ADEjda27Rj2BDmUsdAUppbtnibsiEu07eysjpkP0HOuP+MPsCWCEtN/OqBreMiUJ1qVo
         d1du7yGg1JO36qGvJo4FctUA5Gfhlwob6l43AftGch+qxxVHLGVNnYThz4QcxByjhRCm
         XeJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=yJXaiUYe2SGfZZwuQ9hGJskgqbJWee3wyulwiBKm5Lo=;
        b=F+zw5D6toTyQI7yTMMXTEuJYt7MCLVb+zRBUuws8UK8bLVZRhyHSd23NzNzSJn7JlB
         6fjg4RTI4OgZAwB+buoZKXqcDkycFWO23PTm9oLuZEsZNRrNly39WfLTWcdE+csN9J7i
         Kb3UI/hfMuCDx2YA7NW9+qjmISIr1JfUyQg1QhfuZiqwKrh/jfjfuU5Qf0fvGKPUH2NN
         iJ3Sq6VTTMtsLF8Y3/GTBv7yRoAwjOqLyqHqhBW/BSCRdDtG7cdw2i5l6aktVNs9YM/8
         espUsw5VD6EEWDD+JDyUWi7seVW/roA/yolnNGe5AuPXtMZqw7ALHFLThkEduWw9lFcn
         f7kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p3si5059407plb.101.2019.02.05.23.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 23:24:43 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 23:24:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,339,1544515200"; 
   d="scan'208";a="316707545"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga006.fm.intel.com with ESMTP; 05 Feb 2019 23:24:42 -0800
Subject: [PATCH 0/2] mm/shuffle: Fix + default enable
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, keescook@chromium.org, linux-kernel@vger.kernel.org
Date: Tue, 05 Feb 2019 23:12:05 -0800
Message-ID: <154943712485.3858443.4491117952728936852.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000282, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

Please fold patch1 into:
mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch

Patch2, as marked, is the "always-on" shuffle patch for -mm only.

---

Dan Williams (2):
      mm/shuffle: Fix shuffle enable
      [-mm only] mm/shuffle: Default enable all shuffling


 init/Kconfig |    4 ++--
 mm/shuffle.c |   20 +++++++++++++++++---
 mm/shuffle.h |    2 +-
 3 files changed, 20 insertions(+), 6 deletions(-)

