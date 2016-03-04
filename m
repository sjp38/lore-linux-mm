Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B0EDD6B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 17:34:32 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so38002563wml.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 14:34:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ew3si6120137wjd.140.2016.03.04.14.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 14:34:31 -0800 (PST)
Date: Fri, 4 Mar 2016 14:34:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 0/3] KASAN: clean stale poison upon cold re-entry to
 kernel
Message-Id: <20160304143429.22d7a6fa522956535ba6000e@linux-foundation.org>
In-Reply-To: <1457024068-2236-1-git-send-email-mark.rutland@arm.com>
References: <1457024068-2236-1-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org, mingo@redhat.com, aryabinin@virtuozzo.com, catalin.marinas@arm.com, glider@google.com, lorenzo.pieralisi@arm.com, peterz@infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Thu,  3 Mar 2016 16:54:25 +0000 Mark Rutland <mark.rutland@arm.com> wrote:

> Andrew, the conclusion [5] from v1 was that this should go via the mm tree.
> Are you happy to pick this up? 

yep.  I'll aim to get this into 4.5.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
