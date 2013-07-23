Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 16F086B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 09:44:09 -0400 (EDT)
Date: Tue, 23 Jul 2013 15:44:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2013-07-18-16-40 uploaded
Message-ID: <20130723134407.GE8677@dhcp22.suse.cz>
References: <20130718234123.4170F31C022@corp2gmr1-1.hot.corp.google.com>
 <51E8B34B.1070200@gmail.com>
 <20130719180035.GI17812@cmpxchg.org>
 <20130719111744.ce87390c8d8fa6b0b1c52eb6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719111744.ce87390c8d8fa6b0b1c52eb6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Paul Bolle <paul.bollee@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Fri 19-07-13 11:17:44, Andrew Morton wrote:
[...]
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the
> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> file, http://www.ozlabs.org/~akpm/mmotm/series.

Well, I think "It contains the patches which are mm related." would be
more precise because I am taking also patches which are outside mm (e.g.
shrinkers section currently).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
