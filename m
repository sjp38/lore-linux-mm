Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8F11C6B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 22:35:45 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id v10so107413pde.9
        for <linux-mm@kvack.org>; Mon, 19 May 2014 19:35:45 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id in10si22305207pac.127.2014.05.19.19.35.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 19:35:44 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id p10so106098pdj.7
        for <linux-mm@kvack.org>; Mon, 19 May 2014 19:35:44 -0700 (PDT)
Date: Mon, 19 May 2014 19:34:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
In-Reply-To: <87d2f9jlpd.fsf@rustcorp.com.au>
Message-ID: <alpine.LSU.2.11.1405191930130.3574@eggly.anvils>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <537479E7.90806@linux.vnet.ibm.com> <alpine.LSU.2.11.1405151026540.4664@eggly.anvils> <87wqdik4n5.fsf@rustcorp.com.au> <53797511.1050409@linux.vnet.ibm.com> <alpine.LSU.2.11.1405191531150.1317@eggly.anvils>
 <87d2f9jlpd.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Tue, 20 May 2014, Rusty Russell wrote:
> Hugh Dickins <hughd@google.com> writes:
> >> On Monday 19 May 2014 05:42 AM, Rusty Russell wrote:
> >> > 
> >> > Perhaps we try to generalize from two data points (a slight improvement
> >> > over doing it from 1!), eg:
> >> > 
> >> > /* 4 seems good for 4k-page x86, 0 seems good for 64k page ppc64, so: */
> >> > unsigned int fault_around_order __read_mostly =
> >> >         (16 - PAGE_SHIFT < 0 ? 0 : 16 - PAGE_SHIFT);
> >
> > Rusty's bimodal answer doesn't seem the right starting point to me.
> 
> ?  It's not bimodal, it's graded.  I think you misread?

Yikes, worse than misread, more like I was too rude even to read: sorry!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
