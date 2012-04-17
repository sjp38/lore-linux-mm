Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 233A76B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 12:01:40 -0400 (EDT)
Date: Tue, 17 Apr 2012 11:01:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab corruption
In-Reply-To: <CEBEEFE88D91064B9C04DD88A9AA701501D97F9451@sjcexbe02.DataDomain.com>
Message-ID: <alpine.DEB.2.00.1204171059450.15487@router.home>
References: <CEBEEFE88D91064B9C04DD88A9AA701501D97F9451@sjcexbe02.DataDomain.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-683108511-1334678498=:15487"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagar Borikar <Sagar.Borikar@emc.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-683108511-1334678498=:15487
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 16 Apr 2012, Sagar Borikar wrote:

> We are facing a slab corruption issue while using e1000 net driver in
> certain situations. Its very hard to reproduce the problem as well as
> though we know that what is corrupted, we can=E2=80=99t figure out why it=
s
> corrupted.

Could you rerun your test with CONFIG_DEBUG_SLAB and CONFIG_DEBUG_VM on?
With those you will get more integrity checks and slab diagnostics will
check for memory corruption.

---1463811839-683108511-1334678498=:15487--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
