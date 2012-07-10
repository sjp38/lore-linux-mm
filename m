Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 0B5806B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 14:37:39 -0400 (EDT)
Received: by yhr47 with SMTP id 47so382981yhr.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:37:38 -0700 (PDT)
References: <20120710111756.GA11351@localhost>
In-Reply-To: <20120710111756.GA11351@localhost>
Mime-Version: 1.0 (1.0)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <CF1C132D-2873-408A-BCC9-B9F57BE6EDDB@linuxfoundation.org>
From: Christoph Lameter <christoph@linuxfoundation.org>
Subject: Re: linux-next: Early crashed kernel on CONFIG_SLOB
Date: Tue, 10 Jul 2012 13:37:35 -0500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "wfg@linux.intel.com" <wfg@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

I sent a patch yesterday (or was it friday) to fix the issue. Sorry @airport=
 right now.=20



On Jul 10, 2012, at 6:17, wfg@linux.intel.com wrote:

> Hi Christoph,
>=20
> This commit crashes the kernel w/o any dmesg output (the attached one
> is created by the script as a summary for that run). This is very
> reproducible in kvm for the attached config.
>=20
>        commit 3b0efdfa1e719303536c04d9abca43abeb40f80a
>        Author: Christoph Lameter <cl@linux.com>
>        Date:   Wed Jun 13 10:24:57 2012 -0500
>=20
>            mm, sl[aou]b: Extract common fields from struct kmem_cache
>=20
> Thanks,
> Fengguang
> <dmesg-kvm-waimea-2191-2012-07-10-17-32-01>
> <config-3.5.0-rc6+>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
