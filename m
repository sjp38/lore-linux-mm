Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id D46786B003B
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 21:43:02 -0400 (EDT)
From: Lisa Du <cldu@marvell.com>
Date: Tue, 6 Aug 2013 18:42:06 -0700
Subject: RE: [resend] [PATCH V2] mm: vmscan: fix do_try_to_free_pages()
 livelock
Message-ID: <89813612683626448B837EE5A0B6A7CB3B63175BCA@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
 <20130805074146.GD10146@dhcp22.suse.cz>
 <89813612683626448B837EE5A0B6A7CB3B630BED6B@SC-VEXCH4.marvell.com>
 <20130806103543.GA31138@dhcp22.suse.cz>
In-Reply-To: <20130806103543.GA31138@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, "yinghan@google.com" <yinghan@google.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>Christoph Lameter <cl@linux.com>

Hi, Michal and all
   I'm so sorry, now I updated the review list.
   Thank you all for the review and comments!

In this version:
Remove change ID according to Minchan's comment;
Reorder the check in shrink_zones according Johannes's comment.
Also cc to more people.
