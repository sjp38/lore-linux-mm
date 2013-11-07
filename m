Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 80EBF6B0152
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 07:06:33 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so517766pab.32
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 04:06:33 -0800 (PST)
Received: from psmtp.com ([74.125.245.156])
        by mx.google.com with SMTP id ru9si2419278pbc.198.2013.11.07.04.06.31
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 04:06:32 -0800 (PST)
Received: by mail-ve0-f182.google.com with SMTP id jy13so299878veb.13
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 04:06:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	<1383773827.11046.355.camel@schen9-DESK>
	<CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
	<CANN689HkNP-UZOu+vDCFPG5_k=BNZG6a+oP+Ope16vLc2ShFzw@mail.gmail.com>
Date: Thu, 7 Nov 2013 21:06:29 +0900
Message-ID: <CA+55aFwn1HUt3iXo6Zz8j1HUJi+qJ1NfcnUz-P+XCYLL7gjCMQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=089e0115f6828bdaee04ea95184d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, linux-kernel@vger.kernel.org, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

--089e0115f6828bdaee04ea95184d
Content-Type: text/plain; charset=UTF-8

On Nov 7, 2013 6:55 PM, "Michel Lespinasse" <walken@google.com> wrote:
>
> Rather than writing arch-specific locking code, would you agree to
> introduce acquire and release memory operations ?

Yes, that's probably the right thing to do. What ops do we need? Store with
release, cmpxchg and load with acquire? Anything else?

      Linus

--089e0115f6828bdaee04ea95184d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Nov 7, 2013 6:55 PM, &quot;Michel Lespinasse&quot; &lt;<a href=3D"mailto=
:walken@google.com">walken@google.com</a>&gt; wrote:<br>
&gt;<br>
&gt; Rather than writing arch-specific locking code, would you agree to<br>
&gt; introduce acquire and release memory operations ?</p>
<p dir=3D"ltr">Yes, that&#39;s probably the right thing to do. What ops do =
we need? Store with release, cmpxchg and load with acquire? Anything else?<=
/p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>

--089e0115f6828bdaee04ea95184d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
