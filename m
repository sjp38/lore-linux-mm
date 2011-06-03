Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B9BDF6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 10:06:50 -0400 (EDT)
Date: Fri, 3 Jun 2011 09:06:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: always align cpu_slab to honor cmpxchg_double
 requirement
In-Reply-To: <BANLkTinjCbhiwRfQ_aN5wtbYipQB6gv5AA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1106030905590.27151@router.home>
References: <201106021424.p52EO91O006974@lab-17.internal.tilera.com> <alpine.DEB.2.00.1106021015220.18350@chino.kir.corp.google.com> <4DE7D2AC.1070503@tilera.com> <BANLkTinjCbhiwRfQ_aN5wtbYipQB6gv5AA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1379602815-1307110008=:27151"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1379602815-1307110008=:27151
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 3 Jun 2011, Pekka Enberg wrote:

> > No, in 2.6.39 the irqsafe_cpu_cmpxchg_double() was guarded under "#ifde=
f
> > CONFIG_CMPXCHG_LOCAL". =A0Now it's not. =A0I suppose we could take the =
comment
> > change in percpu.h for 2.6.39, but it probably doesn't merit churning t=
he
> > stable tree.
>
> Yup. Looks good. Christoph?

Ok if we do not mind the packing density to be not that tight anymore.

Acked-by: Christoph Lameter <cl@linux.com>

---1463811839-1379602815-1307110008=:27151--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
