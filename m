Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B4C856B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 14:26:44 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <94c9f8f7-4ea0-44ce-9938-85e31867b8fe@default>
Date: Fri, 5 Aug 2011 11:26:32 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V4 0/4] mm: frontswap: overview
References: <20110527194804.GA27109@ca-server1.us.oracle.com
 4E3C1292.9080506@linux.vnet.ibm.com>
In-Reply-To: <4E3C1292.9080506@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, ngupta@vflare.org, Brian King <brking@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Friday, August 05, 2011 9:56 AM
> To: Dan Magenheimer
> Cc: linux-mm@kvack.org; ngupta@vflare.org; Brian King
> Subject: Re: [PATCH V4 0/4] mm: frontswap: overview
>=20
> Dan,
>=20
> What is the plan for getting this upstream?  Are there some issues or obj=
ections that haven't been
> addressed?
> --
> Seth

Hi Seth --

The only significant objection I'm aware of is that there hasn't been
a strong demand for frontswap yet, partly due to the fact that most
of the interested parties have been communicating offlist.

Can I take this email as an "Acked-by"?  I will be posting V5
next week (V4->V5: an allocation-time bug fix by Bob Liu, a
handful of syntactic clarifications reported by Konrad Wilk,
and rebase to linux-3.1-rc1.)  Soon after, V5 will be in linux-next
and I plan to lobby the relevant maintainers to merge frontswap
for the linux-3.2 window... and would welcome your public support.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
