From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/3] explicitly document overloaded page flags
Message-ID: <exportbomb.1210871946@pinky>
Date: Thu, 15 May 2008 18:19:38 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

With the recent page flag reorganisation we have a single enum which
defines the valid page flags and their values, nice and clear.  However
there are a number of bits which are overloaded by different subsystems.
Firstly there is PG_owner_priv_1 which is used by filesystems and by XEN.
Secondly both SLOB and SLUB use a couple of extra page bits to manage
internal state for pages they own; both overlay other bits.  All of these
"aliases" are scattered about the source making it very hard for a reader
to know if the bits are safe to rely on in all contexts; confusion here
is bad.

As we now have a single place where the bits are clearly assigned it makes
sense to clarify the reuse of bits by making the aliases explicit and
visible with the original bit assignments.  This patch creates explicit
aliases within the enum itself for the overloaded bits and uses those
aliases throughout.

Andrew please consider for -mm.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
