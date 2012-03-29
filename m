Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 034636B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 18:53:44 -0400 (EDT)
Message-ID: <4F74E7CD.3030807@ah.jp.nec.com>
Date: Thu, 29 Mar 2012 18:53:01 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] pagemap: fix order of pmd_trans_unstable() and pmd_trans_huge_lock()
References: <1333010501-31218-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20120329202514.GC20930@redhat.com>
In-Reply-To: <20120329202514.GC20930@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <levinsasha928@gmail.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(3/29/2012 16:25), Andrea Arcangeli wrote:
> Hi,
> 
> On Thu, Mar 29, 2012 at 04:41:41AM -0400, Naoya Horiguchi wrote:
>> pmd_trans_unstable() in pagemap_pte_range() comes before pmd_trans_huge_lock()
>> now, which means that pagewalk kicked by reading /proc/pid/pagemap does not
>> run over thp. This patch fixes it.
> 
> This should be fixed already.

Oh, you're right. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
