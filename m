Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 30F3C6B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 15:43:15 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Mon, 31 Aug 2009 12:43:07 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E8932601841832F9@azsmsx502.amr.corp.intel.com>
References: <4A7AAE07.1010202@redhat.com>
 <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost>
 <4A7AC201.4010202@redhat.com> <20090806130631.GB6162@localhost>
 <4A7AD79E.4020604@redhat.com> <20090816032822.GB6888@localhost>
 <4A878377.70502@redhat.com> <20090816045522.GA13740@localhost>
 <9EECC02A4CC333418C00A85D21E89326B6611F25@azsmsx502.amr.corp.intel.com>
 <20090821182439.GN29572@balbir.in.ibm.com>
In-Reply-To: <20090821182439.GN29572@balbir.in.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu,
 Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> What do the stats for / from within kvm look like?

Interesting - what they look like is inactive_anon is always zero.  Details=
 below - I took the host numbers at the same time and they are similar to w=
hat I reported before.

					Jeff

The fields are inactive_anon, active_anon, inactive_file, active_file - sho=
rtly after the data started being collected, I started firefox and an edito=
r thingy.  The data continues as far into the shutdown as it could.

0 10858 13516 3279
0 10872 13516 3286
0 10867 13513 3286
0 11455 13268 3552
0 13068 12871 3949
0 13281 12810 4012
0 13701 12719 4103
0 14133 12631 4191
0 10878 11742 5087
0 10878 11741 5085
0 10878 11741 5085
0 10877 11741 5085
0 10877 11741 5085
0 10878 11741 5085
0 10878 11741 5085
0 10877 11741 5085
0 10905 11741 5085
0 11118 11776 5106
0 11594 14541 5169
0 11084 15314 5248
0 12022 15686 5300
0 12813 16379 5608
0 13614 16744 5915
0 14230 16849 5936
0 14461 16943 5953
0 14706 17412 5967
0 15574 17445 6011
0 15623 17459 6011
0 15596 17461 6015
0 15941 17523 6048
0 16508 17684 6048
0 17095 18154 6056
0 18635 18175 6056
0 18867 18195 6060
0 18972 18195 6060
0 18975 18185 6073
0 19220 18234 6073
0 19809 18276 6076
0 19571 18276 6076
0 19567 18276 6076
0 19588 18276 6076
0 19588 18276 6076
0 19588 18276 6076
0 19589 18276 6076
0 19603 18276 6076
0 19607 18277 6077
0 19600 18277 6077
0 19034 18235 6119
0 19041 18235 6119
0 19040 18233 6121
0 19040 18233 6121
0 18724 18240 6121
0 11674 16376 7977
0 11674 16376 7977
0 11673 16376 7977
0 11708 16376 7977
0 11703 16374 7979
0 11703 16374 7979
0 11702 16374 7979
0 11702 16374 7979
0 11716 16374 7979
0 11716 16374 7979
0 11718 16374 7979
0 11711 16374 7979
0 11811 16413 7986
0 11811 16413 7986
0 11897 16413 7986
0 12247 16434 7986
0 12495 16457 7990
0 12495 16457 7990
0 12491 16457 7990
0 12491 16457 7990
0 12737 16457 7990
0 11844 16457 7990
0 10969 16436 8011
0 9586 16140 8328
0 9209 16253 8333
0 8467 16120 8550
0 7857 16504 8592
0 7215 16467 8681
0 7194 16481 8723
0 7155 16475 8730

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
