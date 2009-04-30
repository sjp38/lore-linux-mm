Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BD90F6B0047
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 14:03:18 -0400 (EDT)
Date: Thu, 30 Apr 2009 10:58:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
Message-Id: <20090430105828.3e248922.akpm@linux-foundation.org>
In-Reply-To: <20090430204624.358c4a2e@woof.tlv.redhat.com>
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com>
	<1240191366-10029-2-git-send-email-ieidus@redhat.com>
	<1240191366-10029-3-git-send-email-ieidus@redhat.com>
	<1240191366-10029-4-git-send-email-ieidus@redhat.com>
	<1240191366-10029-5-git-send-email-ieidus@redhat.com>
	<1240191366-10029-6-git-send-email-ieidus@redhat.com>
	<20090427153421.2682291f.akpm@linux-foundation.org>
	<49F63BC0.9090804@redhat.com>
	<20090430204624.358c4a2e@woof.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 20:46:24 +0300 Izik Eidus <ieidus@redhat.com> wrote:

> Following patchs change the api to be more robust, the result change of
> the api came after conversation i had with Andrea and Chris about how
> to make the api as stable as we can,
> 
> In addition i hope this patchset fix the cross compilation problems, i
> compiled it on itanium (doesnt have _PAGE_RW) and it seems to work.

eek, please don't send multiple patches per email - it's surprisingly
disruptive to everything.

What is the relationship between these patches and the ones I merged
the other day?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
