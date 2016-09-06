Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C50F16B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 16:20:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x24so80651116pfa.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 13:20:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id es17si28931380pac.133.2016.09.06.13.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 13:20:01 -0700 (PDT)
Date: Tue, 6 Sep 2016 13:20:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] mm: cleanup pfn_t usage in track_pfn_insert()
Message-Id: <20160906132001.cd465767fa9844ddeb630cc4@linux-foundation.org>
In-Reply-To: <147318058712.30325.12749411762275637099.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
	<147318058712.30325.12749411762275637099.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@ml01.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 06 Sep 2016 09:49:47 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> Now that track_pfn_insert() is no longer used in the DAX path, it no
> longer needs to comprehend pfn_t values.

What's the benefit in this?  A pfn *should* have type pfn_t, shouldn't
it?   Confused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
