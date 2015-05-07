Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 10AE46B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 08:27:25 -0400 (EDT)
Received: by wief7 with SMTP id f7so12679179wie.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 05:27:24 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id hj8si3018185wjc.149.2015.05.07.05.27.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 05:27:23 -0700 (PDT)
Received: by wgiu9 with SMTP id u9so41783143wgi.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 05:27:23 -0700 (PDT)
Date: Thu, 7 May 2015 14:27:18 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH RFC 01/15] uaccess: count pagefault_disable() levels in
 pagefault_disabled
Message-ID: <20150507122718.GA17296@gmail.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
 <1430934639-2131-2-git-send-email-dahi@linux.vnet.ibm.com>
 <20150507102254.GE23123@twins.programming.kicks-ass.net>
 <20150507125053.5d2e8f0a@thinkpad-w530>
 <20150507111231.GF23123@twins.programming.kicks-ass.net>
 <20150507134030.137deeb2@thinkpad-w530>
 <20150507115118.GT21418@twins.programming.kicks-ass.net>
 <20150507141439.160cb979@thinkpad-w530>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150507141439.160cb979@thinkpad-w530>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <dahi@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org


* David Hildenbrand <dahi@linux.vnet.ibm.com> wrote:

> @Ingo, do you have a strong feeling against this whole 
> patchset/idea?

No objections, sounds good to me now.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
