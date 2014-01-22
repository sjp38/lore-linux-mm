Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB1A6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 16:15:52 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id l18so9856wgh.3
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:15:51 -0800 (PST)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
        by mx.google.com with ESMTPS id ka5si7642339wjc.46.2014.01.22.13.15.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 13:15:51 -0800 (PST)
Received: by mail-wg0-f45.google.com with SMTP id n12so849043wgh.12
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:15:51 -0800 (PST)
From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [PATCH v8 6/6] MCS Lock: Allow architecture specific asm files to be used for contended case
Date: Wed, 22 Jan 2014 21:15:40 +0000
Message-ID: <26254409.YmoYKsf1IQ@radagast>
In-Reply-To: <1390267479.3138.40.camel@schen9-DESK>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com> <1390267479.3138.40.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1685149.4BrWz72eY4"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>


--nextPart1685149.4BrWz72eY4
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi,

On Monday 20 January 2014 17:24:39 Tim Chen wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> This patch allows each architecture to add its specific assembly optimized
> arch_mcs_spin_lock_contended and arch_mcs_spinlock_uncontended for
> MCS lock and unlock functions.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Where possible can you try and maintain the sort order in the Kbuild files?

Cheers
James
--nextPart1685149.4BrWz72eY4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJS4DUEAAoJEKHZs+irPybfVl8P/2gAXU9shCLWJ4waYAvVavNp
Sdy+1TO16jc4vs+R7XAdeAwVZDH1an2uu8q6lE8+J4fXo7kiYolNTiivFQUy+7g3
MWUDuukDM+A5RyDPkjUxgM+1F4br8HoRa4rWH4lB4AW3ceOlA2erLj7rJat8ZetD
RSipQNzjkA5xibteRVeifA++QAQlTBxzDZPkP61YB8OcKpQhldK2I6T8nt/C6WYH
fcsTFKZ+f0/N84IiJTNolWVcxB0ZWWWrlNxbqcQBXTHzPcPka4K341UFkO3nwFwu
V/YY7gup6LSnomN7lue0quQnhul4MOiu85E33LSzMBDiYuDV6mbsJYjj62RcDymy
69v0Pj1Z/NKb0+M5qT/TvHvFTS0rb1j8MSw8PwjpcrhJL2kyYC8kTip++3govhFT
ffLLNou/XReHM5e7UnVrn8pdnH+6ABV1vqH8quFmEOOrZtIxqOtr40T/EIoYI9wT
evYJSfsBi0Yhiw37wAep4tNuDxUyDddxhGHrt75aSKq+PCfstvoDRgW1MFUntcP5
VUN69DRU0IXoZTMavnX66DE/Oa2FC4ZO350bsxXR4IFvWkrGQbqPCuWKhwViawZf
FuAI5HaMk59FBhTLKQuYwaV8L7mxQFJ/huV/+MMI9fAKyPsNovbG8mDbalzxNSjI
SWps+aGNHg6q4de46SQv
=ml5/
-----END PGP SIGNATURE-----

--nextPart1685149.4BrWz72eY4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
