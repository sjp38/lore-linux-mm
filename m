Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DC7FB8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:12:52 -0400 (EDT)
Date: Tue, 19 Apr 2011 12:12:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1104191211480.17888@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz> <alpine.LSU.2.00.1104171952040.22679@sister.anvils> <20110418100131.GD8925@tiehlicka.suse.cz> <20110418135637.5baac204.akpm@linux-foundation.org> <20110419111004.GE21689@tiehlicka.suse.cz>
 <1303228009.3171.18.camel@mulgrave.site> <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-755122748-1303233170=:17888"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-755122748-1303233170=:17888
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 19 Apr 2011, Pekka Enberg wrote:

> On Tue, Apr 19, 2011 at 6:46 PM, James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
> > It compiles OK, but crashes on boot in fsck. =A0The crash is definitely=
 mm
> > but looks to be a slab problem (it's a null deref on a spinlock in
> > add_partial(), which seems unrelated to this patch).

That means that the per node structures have not been setup yet. Node
hotplug not working?

> > It seems to be a random intermittent mm crash because the next reboot
> > crashed with the same trace but after the fsck had completed and the
> > third came up to the login prompt.
>
> Looks like a genuine SLUB problem on parisc. Christoph?

Race between node hotplug and use of the slab on that node?

---1463811839-755122748-1303233170=:17888--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
