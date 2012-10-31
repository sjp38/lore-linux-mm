Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 560E36B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 10:43:32 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c0d68556-54e7-479a-a7ae-6ca6f136d62d@default>
Date: Wed, 31 Oct 2012 07:42:39 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/2] mm: do not call frontswap_init() during swapoff
References: <<1351372847-13625-1-git-send-email-cesarb@cesarb.net>>
In-Reply-To: <<1351372847-13625-1-git-send-email-cesarb@cesarb.net>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

> From: Cesar Eduardo Barros [mailto:cesarb@cesarb.net]
> Sent: Saturday, October 27, 2012 3:21 PM
> To: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org; Konrad Rzeszutek Wilk; Dan Magenheimer;=
 Andrew Morton; Mel Gorman;
> Rik van Riel; KAMEZAWA Hiroyuki; Johannes Weiner; Cesar Eduardo Barros
> Subject: [PATCH 0/2] mm: do not call frontswap_init() during swapoff
>=20
> The call to frontswap_init() was added in a place where it is called not
> only from sys_swapon, but also from sys_swapoff. This pair of patches
> fixes that.
>=20
> The first patch moves the acquisition of swap_lock from enable_swap_info
> to two separate helpers, one for sys_swapon and one for sys_swapoff. As
> a bonus, it also makes the code for sys_swapoff less subtle.
>=20
> The second patch moves the call to frontswap_init() from the common code
> to the helper used only by sys_swapon.
>=20
> Compile-tested only, but should be safe.
>=20
> Cesar Eduardo Barros (2):
>   mm: refactor reinsert of swap_info in sys_swapoff
>   mm: do not call frontswap_init() during swapoff
>=20
>  mm/swapfile.c | 26 +++++++++++++++++---------
>  1 file changed, 17 insertions(+), 9 deletions(-)

Belated but, I'm told, better late than never.

Minimally tested to ensure that frontswap continues
to work properly with some disk swap activity, not
exhaustively tested for swap in general.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
