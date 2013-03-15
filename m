Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id B463F6B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 13:05:32 -0400 (EDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 15 Mar 2013 17:03:25 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9B47A1B08061
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 17:05:28 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2FH5Jfr4194536
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 17:05:19 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2FH5RqV016595
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 11:05:28 -0600
Date: Fri, 15 Mar 2013 18:05:21 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v2] mm/hugetlb: add more arch-defined huge_pte functions
Message-ID: <20130315180521.618460c5@vbox-ubuntu>
In-Reply-To: <20130315160241.GD28311@dhcp22.suse.cz>
References: <1363283463-50880-1-git-send-email-gerald.schaefer@de.ibm.com>
	<20130315160241.GD28311@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, "David
 S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Fri, 15 Mar 2013 17:02:41 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 14-03-13 18:51:03, Gerald Schaefer wrote:
> > Commit abf09bed3c "s390/mm: implement software dirty bits"
> > introduced another difference in the pte layout vs. the pmd layout
> > on s390, thoroughly breaking the s390 support for hugetlbfs. This
> > requires replacing some more pte_xxx functions in mm/hugetlbfs.c
> > with a huge_pte_xxx version.
> > 
> > This patch introduces those huge_pte_xxx functions and their
> > generic implementation in asm-generic/hugetlb.h, which will now be
> > included on all architectures supporting hugetlbfs apart from s390.
> > This change will be a no-op for those architectures.
> > 
> > Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
> yes this looks much better. I cannot talk about s390 part because I am
> not familiar with it but the rest looks good to me.
> 
> Maybe one nit, though. pte_page and pte_same do not have their
> huge_Foo counterparts.

Yes, a few pte_xxx calls remain. I left those because they still
work on s390 (and all other archs apparently). I am thinking about
a more complete cleanup, maybe eliminating the ambiguous use of pte_t
for hugetlb completely. Not sure if I can get to it before Martin
introduces the next s390 pte changes :)

Thanks,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
