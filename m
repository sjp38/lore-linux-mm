Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id D384A6B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 08:26:38 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so5327764vcb.14
        for <linux-mm@kvack.org>; Mon, 27 Aug 2012 05:26:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120827123917.3313dfda@thinkpad>
References: <20120823171733.595087166@de.ibm.com>
	<20120823171854.580076595@de.ibm.com>
	<CAJd=RBBJa934R53AHYVhkxE+2e=RiKU1zJXsLMCBFw_NHZE0oQ@mail.gmail.com>
	<20120827123917.3313dfda@thinkpad>
Date: Mon, 27 Aug 2012 20:26:36 +0800
Message-ID: <CAJd=RBA-GyFvQ3_vMVqhBS89QT_xDLEBbysBzhCA7sU7rt00+g@mail.gmail.com>
Subject: Re: [RFC patch 3/7] thp: make MADV_HUGEPAGE check for mm->def_flags
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com, linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Mon, Aug 27, 2012 at 6:39 PM, Gerald Schaefer
<gerald.schaefer@de.ibm.com> wrote:
> Hmm, architecture #ifdefs in common code are ugly. I'd rather keep
> the check even if it is redundant right now for other architectures
> than s390. It is not a performance critical path, and there may be
> other users of that in the future.

Fair if no changes in semantics

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
