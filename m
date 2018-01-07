Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 517806B0270
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 04:21:57 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w18so5351350wra.5
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 01:21:57 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id n24si7332107wra.405.2018.01.07.01.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jan 2018 01:21:56 -0800 (PST)
Message-ID: <1515316905.9212.5.camel@gmx.de>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
From: Mike Galbraith <efault@gmx.de>
Date: Sun, 07 Jan 2018 10:21:45 +0100
In-Reply-To: <20180107091115.GB29329@kroah.com>
References: <20171222084623.668990192@linuxfoundation.org>
	 <20171222084625.007160464@linuxfoundation.org>
	 <1515302062.6507.18.camel@gmx.de> <20180107091115.GB29329@kroah.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Sun, 2018-01-07 at 10:11 +0100, Greg Kroah-Hartman wrote:
> On Sun, Jan 07, 2018 at 06:14:22AM +0100, Mike Galbraith wrote:
> > On Fri, 2017-12-22 at 09:45 +0100, Greg Kroah-Hartman wrote:
> > > 4.14-stable review patch.  If anyone has any objections, please let m=
e know.
> >=20
> > FYI, this broke kdump, or rather the makedumpfile part thereof.
> > =A0Forward looking wreckage is par for the kdump course, but...
>=20
> Is it also broken in Linus's tree with this patch?  Or is there an
> add-on patch that I should apply to 4.14 to resolve this issue there?

Yeah, it's belly up. =A0By its very nature, it's gonna get dinged up
regularly. =A0I only mentioned it because it's not expected that stuff
gets dinged up retroactively.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
