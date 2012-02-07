Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 713EA6B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 10:12:51 -0500 (EST)
Date: Tue, 7 Feb 2012 09:12:48 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [rfc PATCH]slub: per cpu partial statistics change
In-Reply-To: <1328591165.12669.168.camel@debian>
Message-ID: <alpine.DEB.2.00.1202070910320.29500@router.home>
References: <1328256695.12669.24.camel@debian>  <alpine.DEB.2.00.1202030920060.2420@router.home>  <4F2C824E.8080501@intel.com>  <alpine.DEB.2.00.1202060858510.393@router.home> <1328591165.12669.168.camel@debian>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1382060301-1328627569=:29500"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1382060301-1328627569=:29500
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 7 Feb 2012, Alex,Shi wrote:

> Yes, I want to account the unfreeze_partials=EF=BC=88=EF=BC=89 actions in
> put_cpu_partial=EF=BC=88). The unfreezing accounting isn't conflict or re=
peat
> with the cpu_partial_free accounting, since they are different actions
> for the PCP.

Well what is happening here is that the whole per cpu partial list is
moved back to the per node partial list.

CPU_PARTIAL_DRAIN_TO_NODE_PARTIAL ?

A bit long I think. CPU_PARTIAL_DRAIN?

UNFREEZE does not truly reflect what is going on here.

---1463811839-1382060301-1328627569=:29500--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
