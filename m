Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 057CF5F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 07:39:03 -0400 (EDT)
Date: Thu, 16 Apr 2009 13:39:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090416113931.GF4524@random.random>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com> <1239249521-5013-2-git-send-email-ieidus@redhat.com> <1239249521-5013-3-git-send-email-ieidus@redhat.com> <1239249521-5013-4-git-send-email-ieidus@redhat.com> <1239249521-5013-5-git-send-email-ieidus@redhat.com> <20090414150929.174a9b25.akpm@linux-foundation.org> <49E67F17.1070805@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49E67F17.1070805@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 15, 2009 at 05:43:03PM -0700, Jeremy Fitzhardinge wrote:
> Shouldn't that be kmap_atomic's job anyway?  Otherwise it would be hard to 

No because those are full noops in no-highmem kernels. I commented in
other email why I think it's safe thanks to the wrprotect + smp tlb
flush of the userland PTE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
