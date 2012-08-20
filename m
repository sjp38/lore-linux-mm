Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B6F3C6B0069
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 07:11:01 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Repeated fork() causes SLAB to grow without bound
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu>
	<502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
Date: Mon, 20 Aug 2012 04:11:00 -0700
In-Reply-To: <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	(Michel Lespinasse's message of "Mon, 20 Aug 2012 02:39:26 -0700")
Message-ID: <m2d32l95tn.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michel Lespinasse <walken@google.com> writes:
>
> I would still prefer if we could just remove the anon_vma_chain stuff, though.

Would probably help with the fork locking problems too. 
We never really recovered from that regression.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
