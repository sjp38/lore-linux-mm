Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id EE83F6B00EF
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 20:30:16 -0500 (EST)
Received: by iajr24 with SMTP id r24so10240380iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 17:30:16 -0800 (PST)
Date: Tue, 6 Mar 2012 17:29:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] memcg: fix mapcount check in move charge code for
 anonymous page
In-Reply-To: <1331076667-11118-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.00.1203061722040.1431@eggly.anvils>
References: <1331076667-11118-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue, 6 Mar 2012, Naoya Horiguchi wrote:
> 
> IMO, ideally the charge of shared (both file and anon) pages should
> be accounted for all cgroups to which the processes mapping the pages
> belong to, where each charge is weighted by inverse number of mapcount.
> I think accounting total number of mapcount with another counter does
> not work, because the weight of charge depends on each page and the
> total count of mapcount doesn't describe the proportion among cgroups.
> But anyway, it adds more complexity and needs much work, so is not
> a short term fix.

That "ideal" complexity was considered before the current memcg approach
went in.  We elected to go with the less satisfying, but much simpler,
single-owner approach, and it does seem to have paid off.  I believe
that even those who had successfully developed a more complex approach
have since abandoned it for performance scalability reasons.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
