Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC956B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 10:01:11 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so2829288pdj.4
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 07:01:11 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sf3si4900161pac.370.2014.04.25.07.01.09
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 07:01:10 -0700 (PDT)
Date: Fri, 25 Apr 2014 10:01:01 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v3 5/7] swap: Use bdev_read_page() / bdev_write_page()
Message-ID: <20140425140100.GF5886@linux.intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
 <9fb0b4031b0fba312963a7cc21bf258d944cddcf.1397429628.git.matthew.r.wilcox@intel.com>
 <20140424111817.9cc62b2ff1e368c5cf27d262@linux-foundation.org>
 <20140424185740.GE5886@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140424185740.GE5886@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Thu, Apr 24, 2014 at 02:57:40PM -0400, Matthew Wilcox wrote:
> By calling the device driver to write the page directly, we avoid
> allocating a BIO, which allows us to free memory without allocating
> memory.

I got handed some performance numbers last night!  Next time you're updating
the patch description, please use:

By calling the device driver to write the page directly, we avoid
allocating a BIO, which allows us to free memory without allocating
memory.  When running a swap-heavy benchmark, system time is reduced by
about 20%.

Tested-by: Dheeraj Reddy <dheeraj.reddy@intel.com>
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
