Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8F56B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 05:52:11 -0500 (EST)
Received: by mail-lf0-f50.google.com with SMTP id h129so24587817lfh.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:52:11 -0800 (PST)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id a67si5279891lfa.238.2016.01.28.02.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 02:52:10 -0800 (PST)
Received: by mail-lf0-x22e.google.com with SMTP id 17so24275622lfz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:52:09 -0800 (PST)
Date: Thu, 28 Jan 2016 13:52:07 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: polish virtual memory accounting
Message-ID: <20160128105207.GB26641@uranus>
References: <145397434479.24456.7330581149702545550.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145397434479.24456.7330581149702545550.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Thu, Jan 28, 2016 at 12:45:44PM +0300, Konstantin Khlebnikov wrote:
> * add VM_STACK as alias for VM_GROWSUP/DOWN depending on architecture
> * always account VMAs with flag VM_STACK as stack (as it was before)
> * cleanup classifying helpers
> * update comments and documentation
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

Great, thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
