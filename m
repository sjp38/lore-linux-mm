Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 8A3956B0073
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:42:48 -0500 (EST)
Date: Mon, 16 Jan 2012 14:43:08 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch] mm: memcg: update the correct soft limit tree during
 migration
Message-ID: <20120116124308.GA25981@shutemov.name>
References: <1326469291-5642-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1326469291-5642-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 13, 2012 at 04:41:31PM +0100, Johannes Weiner wrote:
> end_migration() passes the old page instead of the new page to commit
> the charge.  This page descriptor is not used for committing itself,
> though, since we also pass the (correct) page_cgroup descriptor.  But
> it's used to find the soft limit tree through the page's zone, so the
> soft limit tree of the old page's zone is updated instead of that of
> the new page's, which might get slightly out of date until the next
> charge reaches the ratelimit point.
>=20
> This glitch has been present since '5564e88 memcg: condense
> page_cgroup-to-page lookup points'.
>=20
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>


--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
