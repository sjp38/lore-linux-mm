Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1CD6B0038
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 14:44:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l68so36105298wml.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 11:44:52 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id y6si1455wjg.51.2016.09.13.11.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 11:44:50 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id b184so3661116wma.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 11:44:50 -0700 (PDT)
Date: Tue, 13 Sep 2016 20:44:46 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 2/2] x86: wire up mincore2()
Message-ID: <20160913184445.GA810@gmail.com>
References: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147361510160.17004.6974628969361614698.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <147361510160.17004.6974628969361614698.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>


* Dan Williams <dan.j.williams@intel.com> wrote:

> Add the new the mincore2() symbol to the x86 syscall tables.

Could you please send the patch against -tip? We have this (new) commit in the x86 
tree:

  f9afc6197e9b x86: Wire up protection keys system calls

... which created a new conflict.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
