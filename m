Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 569DF6B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 02:14:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h126so6983371wmf.10
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 23:14:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si2782448wrd.173.2017.08.08.23.14.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Aug 2017 23:14:46 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 08 Aug 2017 23:14:45 -0700
From: Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH] mm/mmu_notifier: fix deadlock from typo
 vm_lock_anon_vma()
In-Reply-To: <20170808225719.20723-1-jglisse@redhat.com>
References: <20170808225719.20723-1-jglisse@redhat.com>
Message-ID: <a976e37559cc899008dee5615880cf4d@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
