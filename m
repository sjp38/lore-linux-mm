Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 253F16B028F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 13:33:30 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so21106489wib.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 10:33:29 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id xs10si14924302wjc.81.2015.07.16.10.33.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 10:33:28 -0700 (PDT)
Date: Thu, 16 Jul 2015 19:33:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [mminit] [ INFO: possible recursive locking detected ]
Message-ID: <20150716173322.GB19282@twins.programming.kicks-ass.net>
References: <20150714000910.GA8160@wfg-t540p.sh.intel.com>
 <20150714103108.GA6812@suse.de>
 <CALYGNiMUXMvvvi-+64Nd6Qb8Db2EiGZ26jbP8yotUHWS4uF1jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiMUXMvvvi-+64Nd6Qb8Db2EiGZ26jbP8yotUHWS4uF1jg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, nicstange@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>

On Thu, Jul 16, 2015 at 08:13:38PM +0300, Konstantin Khlebnikov wrote:
> Rw-sem have special "non-owner" mode for keeping lockdep away.


Nooo, no new ones of those please!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
