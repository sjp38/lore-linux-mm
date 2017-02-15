Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4C6D6B03D8
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 19:20:10 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id j49so221413914otb.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 16:20:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z4si1957143pfd.119.2017.02.14.16.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 16:20:09 -0800 (PST)
Date: Tue, 14 Feb 2017 16:20:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 1/2] mm/autonuma: Let architecture override how the
 write bit should be stashed in a protnone pte.
Message-Id: <20170214162008.bd592c747fc5e167c10ce7b8@linux-foundation.org>
In-Reply-To: <874lzxm41g.fsf@concordia.ellerman.id.au>
References: <1487050314-3892-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1487050314-3892-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<87poilmien.fsf@concordia.ellerman.id.au>
	<abd9d231-c380-95b0-0722-8df7be626968@linux.vnet.ibm.com>
	<874lzxm41g.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michaele@au1.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Tue, 14 Feb 2017 21:59:23 +1100 Michael Ellerman <michaele@au1.ibm.com> wrote:

> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
> 
> > On Tuesday 14 February 2017 11:19 AM, Michael Ellerman wrote:
> >> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
> >>
> >>> Autonuma preserves the write permission across numa fault to avoid taking
> >>> a writefault after a numa fault (Commit: b191f9b106ea " mm: numa: preserve PTE
> >>> write permissions across a NUMA hinting fault"). Architecture can implement
> >>> protnone in different ways and some may choose to implement that by clearing Read/
> >>> Write/Exec bit of pte. Setting the write bit on such pte can result in wrong
> >>> behaviour. Fix this up by allowing arch to override how to save the write bit
> >>> on a protnone pte.
> >> This is pretty obviously a nop on arches that don't implement the new
> >> hooks, but it'd still be good to get an ack from someone in mm land
> >> before I merge it.
> >
> >
> > To get it apply cleanly you may need
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes.patch
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes-fix.patch
> 
> Ah OK, I missed those.
> 
> In that case these two should probably go via Andrew's tree.

Done.  But
mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes.patch is on
hold because Aneesh saw a testing issue, so these two are also on hold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
