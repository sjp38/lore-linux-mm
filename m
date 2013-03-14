Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E8B5D6B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 09:27:51 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id tb18so2158193obb.17
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 06:27:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130314131404.GH11631@dhcp22.suse.cz>
References: <1363114106-30251-1-git-send-email-gerald.schaefer@de.ibm.com>
	<1363114106-30251-2-git-send-email-gerald.schaefer@de.ibm.com>
	<20130314131404.GH11631@dhcp22.suse.cz>
Date: Thu, 14 Mar 2013 21:27:50 +0800
Message-ID: <CAJd=RBDz+02NeErMBVzi-EQSPwtK4zdUC=3gCB7iZKWVrgcbiA@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/hugetlb: add more arch-defined huge_pte_xxx functions
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, Mar 14, 2013 at 9:14 PM, Michal Hocko <mhocko@suse.cz> wrote:
> Ouch, this adds a lot of code that is almost same for all archs except
> for some. Can we just make one common definition and define only those
> that differ, please?
>
Wonder if he is the guy that added THP for s390, which was a model
work in 2012.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
