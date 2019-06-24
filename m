Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED87FC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 18:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B009320657
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 18:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B009320657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F8CA6B0005; Mon, 24 Jun 2019 14:05:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A89B8E0003; Mon, 24 Jun 2019 14:05:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4721B8E0002; Mon, 24 Jun 2019 14:05:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 11EAF6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:05:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so21521031edw.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:05:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=l2lj4p0nYHjVSIQDP/oLSuZe0abc5bKhPnGL30R+n4g=;
        b=QCKLc5B491R436bjFDnWpDoajugfcgzU8i8rnFabqxCe0FwWiq7Ts1/nZOD8cgoN45
         Qzcxqh4c2e4AaNckUR9bMgyegLZAu2EiOBlBrSbPjC48stYHM1cq2MMBBFnETOotZ3Bc
         STlMWgk9GsidHMMViutM4T2yiqBVth90n9EoFaewPQpZGuw90RWHFpMco9PY3NVxosou
         aEaJOymAgdsoI/J9VdTfHP6OWgIRgFSo5xwZGED4+0S7XMCRh5z3oKniaH6+CtJGmtXT
         Ihc16vUHiO6oL2cupLKlWwR0nBWm8DPpG3gU/TUhdwt5QEm4GsSVrNd04Gs0RDFpSlzZ
         Tk9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW4pjVyw/a3TO4Z+8XPjQN5x5jpzi8de4doXomuzbmChSI/KF3x
	ZSHQudMN2LlkoAeGCFY+AauCMG3Km++zSsf/ZpfuFmF1z96cDuBtdVDu2pkzlenYrvwKZjaPyfU
	pPbZEtcqpkbtMTZEQHrkap7VVnPSreoo9H3SjZ69i7HApwstNQmyPYaLnp/8y77CpBg==
X-Received: by 2002:a50:8be8:: with SMTP id n37mr145010722edn.216.1561399556653;
        Mon, 24 Jun 2019 11:05:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxw/tY34aLpDKwuSMzO9656CoMhZxIAUfLmAFHzzepM5Gv1SVMtGQrZGpqZtyDPCiju6JFE
X-Received: by 2002:a50:8be8:: with SMTP id n37mr145010646edn.216.1561399555983;
        Mon, 24 Jun 2019 11:05:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561399555; cv=none;
        d=google.com; s=arc-20160816;
        b=vTAG5CE/X5wAuPlAzVpSZxdpXxD04EQSJq4SxZm281tYbgrEyYe/GezIUln16wrHWF
         P0kfDDuN1JeRA/V6P7Uafq5yuJ+nS1EJPYMDveCkzPml8ejDhY88XN4Qz5qp6M/tcew9
         4SMneGwNJq786DrDNZdW0SwoC4f/8Ao5sQgixaPuWyaw+hBAmnfrrFzXXZqmFm2hY9Tu
         KcQbp9/GVBTjk8o90b3lyZ1jDOTQE3RZkZgAgkn8lrOCkCLDjQw6LV+8MhB3oW9jVVxM
         QYo5yJ6pWx+FWTh+ixJdsmBWPsCGeusSiHZcR3DcCl+IV46GRH3LIndRW3jdQBs18UAL
         R3Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=l2lj4p0nYHjVSIQDP/oLSuZe0abc5bKhPnGL30R+n4g=;
        b=nDiBSr6RvSdNUgqI4pR/0O0XRWV0WmiNrvlu5tPpX1e3k6rd5NB+Fj2VoZPQ5+IKmZ
         OhkClZWXQ3UkcURqbaMETBWDrpsLgwoZSAuyNXHbFFKBD5I3h9rBL0J0JHN5Z8Kk4wg9
         MFaZPtN7QnHK0z2Aw9Dn5JrxMAZemTAWIbO7zP6OlDZvT70R23BP1KczxSUqKNZz3BnY
         9NIFXzFp1j1TKpW6eBrdcVtvcIo2WU4KQl1qtKvYITQnMz5lH22FiIT7b1ShPkZyS8V/
         G5ETgGkAqmWYm6L1xjAnpxC0VKbKs9n3Pt4Nf6Hay2gld9oc63aZSdrf9l6XUH8HAb57
         x8cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z29si10610933edc.143.2019.06.24.11.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 11:05:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 991B3ABD4;
	Mon, 24 Jun 2019 18:05:55 +0000 (UTC)
Message-ID: <1561399554.3073.10.camel@suse.de>
Subject: Re: [PATCH v10 08/13] mm/sparsemem: Prepare for sub-section ranges
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Logan
 Gunthorpe <logang@deltatee.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, linux-mm@kvack.org, 
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Mon, 24 Jun 2019 20:05:54 +0200
In-Reply-To: <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 22:52 -0700, Dan Williams wrote:
> Prepare the memory hot-{add,remove} paths for handling sub-section
> ranges by plumbing the starting page frame and number of pages being
> handled through arch_{add,remove}_memory() to
> sparse_{add,remove}_one_section().
> 
> This is simply plumbing, small cleanups, and some identifier renames.
> No
> intended functional changes.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I already gave my Reviewed-by in the previous version:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

