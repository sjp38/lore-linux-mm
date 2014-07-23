Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E1BA76B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:38:53 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so1925057pdj.21
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 09:38:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gn5si3075517pbb.200.2014.07.23.09.38.52
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 09:38:52 -0700 (PDT)
Message-ID: <53CFE4F9.3000701@intel.com>
Date: Wed, 23 Jul 2014 09:38:17 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 09/10] x86, mpx: cleanup unused bound tables
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com> <1405921124-4230-10-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-10-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/20/2014 10:38 PM, Qiaowei Ren wrote:
> Since the kernel allocated those tables on-demand without userspace
> knowledge, it is also responsible for freeing them when the associated
> mappings go away.
> 
> Here, the solution for this issue is to hook do_munmap() to check
> whether one process is MPX enabled. If yes, those bounds tables covered
> in the virtual address region which is being unmapped will be freed also.

This is the part of the code that I'm the most concerned about.

Could you elaborate on how you've tested this to make sure it works OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
