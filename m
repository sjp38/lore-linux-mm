Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 283FA6B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 23:48:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x7so4796953pfa.19
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 20:48:16 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r3si1084823plb.644.2017.10.18.20.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 20:48:14 -0700 (PDT)
From: "Sandoval Castro, Luis Felipe" <luis.felipe.sandoval.castro@intel.com>
Subject: RE: [PATCH v1] mm/mempolicy.c: Fix get_nodes() off-by-one error.
Date: Thu, 19 Oct 2017 03:48:09 +0000
Message-ID: <A42BA8431884844BBC20FACB734718294A319F85@FMSMSX106.amr.corp.intel.com>
References: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <1507296994-175620-2-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <20171012084633.ipr5cfxsrs3lyb5n@dhcp22.suse.cz>
 <20171012152825.GJ5109@tassilo.jf.intel.com>
 <20171013080403.izjxlrf7ap5zt2d5@dhcp22.suse.cz>
In-Reply-To: <20171013080403.izjxlrf7ap5zt2d5@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andi Kleen <ak@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mingo@kernel.org" <mingo@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "salls@cs.ucsb.edu" <salls@cs.ucsb.edu>, Cristopher Lameter <cl@linux.com>

On Tue 18-10-17 10:42:34, Luis Felipe Sandoval Castro wrote:

Sorry for the delayed replay, from your feedback I don't think my
patch has any chances of being merged... I'm wondering though,
if a note in the man pages "range non inclusive" or something
like that would help to avoid confusions? Thanks

> On Thu 12-10-17 08:28:25, Andi Kleen wrote:
> > On Thu, Oct 12, 2017 at 10:46:33AM +0200, Michal Hocko wrote:
> > > [CC Christoph who seems to be the author of the code]
> >
> > Actually you can blame me. I did the mistake originally.
> > It was found many years ago, but then it was already too late
> > to change.
> >
> > > Andi has voiced a concern about backward compatibility but I am not
> sure
> > > the risk is very high. The current behavior is simply broken unless y=
ou
> > > use a large maxnode anyway. What kind of breakage would you envision
> > > Andi?
> >
> > libnuma uses the available number of nodes as max.
> >
> > So it would always lose the last one with your chance.
>=20
> I must be missing something because libnuma does
> if (set_mempolicy(policy, bmp->maskp, bmp->size + 1) < 0)
>=20
> so it sets max as size + 1 which is exactly what the man page describes.
>=20
> > Your change would be catastrophic.
>=20
> I am not sure which change do you mean here. I wasn't proposing any
> patch (yet). All I was saying is that the docuementation diagrees with
> the in kernel implementation. The only applications that would break
> would be those which do not comply to the documentation AFAICS, no?
> --
> Michal Hocko
> SUSE Labs

Best Regards,
Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
