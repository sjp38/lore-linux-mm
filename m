Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C5F186B0092
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:05:18 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1067918fxm.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 05:05:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110620065907.GA29075@minime.bse>
References: <1308547333-27413-1-git-send-email-lliubbo@gmail.com> <20110620065907.GA29075@minime.bse>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Mon, 20 Jun 2011 08:04:54 -0400
Message-ID: <BANLkTincN9_nxZ3WBELqS4CY6PK_M_0kjw@mail.gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH] nommu: reimplement remap_pfn_range()
 to simply return 0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Daniel_Gl=C3=B6ckner?= <daniel-gl@gmx.net>
Cc: Bob Liu <lliubbo@gmail.com>, gerg@snapgear.com, dhowells@redhat.com, linux-mm@kvack.org, lethal@linux-sh.org, geert@linux-m68k.org, gerg@uclinux.org, uclinux-dist-devel@blackfin.uclinux.org, akpm@linux-foundation.org, walken@google.com

On Mon, Jun 20, 2011 at 02:59, Daniel Gl=C3=B6ckner wrote:
> And I can imagine architectures wanting to do something with the prot fla=
gs.

this func is implemented in common mmu code with no arch callbacks, so
there isnt anything different here.  when bob said "nommu arch", he
wasnt referring to an actual architecture, but to nommu vs mmu memory
management cores.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
