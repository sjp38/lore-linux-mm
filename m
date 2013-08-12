Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 162696B0032
	for <linux-mm@kvack.org>; Sun, 11 Aug 2013 21:55:09 -0400 (EDT)
From: Lisa Du <cldu@marvell.com>
Date: Sun, 11 Aug 2013 18:46:08 -0700
Subject: [resend] [PATCH V3] mm: vmscan: fix do_try_to_free_pages() livelock
Message-ID: <89813612683626448B837EE5A0B6A7CB3B631767D7@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
 <20130805074146.GD10146@dhcp22.suse.cz>
 <89813612683626448B837EE5A0B6A7CB3B630BED6B@SC-VEXCH4.marvell.com>
 <20130806103543.GA31138@dhcp22.suse.cz>
 <89813612683626448B837EE5A0B6A7CB3B63175BCA@SC-VEXCH4.marvell.com>
 <20130808181426.GI715@cmpxchg.org>
In-Reply-To: <20130808181426.GI715@cmpxchg.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, "yinghan@google.com" <yinghan@google.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

In this version:
Reorder the check in pgdat_balanced according Johannes's comment.
