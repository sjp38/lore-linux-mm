Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id CFD276B0073
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:12:36 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so300107wes.22
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 23:12:36 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
        by mx.google.com with ESMTPS id vo10si1223493wjc.86.2014.06.17.23.12.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 23:12:35 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so464112wib.15
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 23:12:34 -0700 (PDT)
Date: Wed, 18 Jun 2014 09:12:30 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in kvm.
Message-ID: <20140618061230.GA10948@minantech.com>
References: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Wed, Jun 18, 2014 at 01:50:00PM +0800, Tang Chen wrote:
> [Questions]
> And by the way, would you guys please answer the following questions for me ?
> 
> 1. What's the ept identity pagetable for ?  Only one page is enough ?
> 
> 2. Is the ept identity pagetable only used in realmode ?
>    Can we free it once the guest is up (vcpu in protect mode)?
> 
> 3. Now, ept identity pagetable is allocated in qemu userspace.
>    Can we allocate it in kernel space ?
What would be the benefit?

> 
> 4. If I want to migrate these two pages, what do you think is the best way ?
> 
I answered most of those here: http://www.mail-archive.com/kvm@vger.kernel.org/msg103718.html

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
