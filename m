Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id D64506B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 16:26:33 -0400 (EDT)
Date: Thu, 29 Mar 2012 22:26:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] pagemap: remove remaining unneeded spin_lock()
Message-ID: <20120329202628.GD20930@redhat.com>
References: <1333010379-31126-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1333010379-31126-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <levinsasha928@gmail.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, Mar 29, 2012 at 04:39:39AM -0400, Naoya Horiguchi wrote:
> commit: 025c5b2451e4 "thp: optimize away unnecessary page table locking"
> moves spin_lock() into pmd_trans_huge_lock() in order to avoid locking
> unless pmd is for thp. So this spin_lock() is a bug.
> 
> Reported-by: Sasha Levin <levinsasha928@gmail.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
