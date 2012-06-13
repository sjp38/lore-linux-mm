Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8013F6B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 16:31:05 -0400 (EDT)
Date: Wed, 13 Jun 2012 22:31:03 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v2
Message-ID: <20120613203103.GG11413@one.firstfloor.org>
References: <1339542816-21663-1-git-send-email-andi@firstfloor.org> <4FD8F70F.7080405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD8F70F.7080405@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed, Jun 13, 2012 at 04:24:47PM -0400, Rik van Riel wrote:
> This would also be useful for emulators such as qemu-kvm,
> which want the guest memory to be 2MB aligned.

hugetlbfs does implicit align, so right now I mash
the two together and use up many of the remaining bits

If you want align different than page sizes you may need
to go 64bits with the flags.

Is there a use case for alignment independent of page sizes?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
