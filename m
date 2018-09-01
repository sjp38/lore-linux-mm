Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 32E976B5EF4
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 18:33:24 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 1-v6so20493285qtp.10
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 15:33:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b87-v6sor7090182qkj.54.2018.09.01.15.33.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Sep 2018 15:33:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com> <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
From: Wes Turner <wes.turner@gmail.com>
Date: Sat, 1 Sep 2018 18:33:22 -0400
Message-ID: <CACfEFw_h5uup-anKZwfBcWMJB7gHxb9NEPTRSUAY0+t11RiQbg@mail.gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Content-Type: multipart/alternative; boundary="00000000000054a9830574d6e505"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "jsteckli@amazon.de" <jsteckli@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

--00000000000054a9830574d6e505
Content-Type: text/plain; charset="UTF-8"

Speaking of pages and slowdowns,
is there a better place to ask this question:

>From "'Turning Tables' shared page tables vuln":

"""
'New "Turning Tables" Technique Bypasses All Windows Kernel Mitigations'
https://www.bleepingcomputer.com/news/security/new-turning-tables-technique-bypasses-all-windows-kernel-mitigations/

> Furthermore, since the concept of page tables is also used by Apple and
the Linux project, macOS and Linux are, in theory, also vulnerable to this
technique, albeit the researchers have not verified such attacks, as of yet.

Slides:
https://cdn2.hubspot.net/hubfs/487909/Turning%20(Page)%20Tables_Slides.pdf

Naturally, I took notice and decided to forward the latest scary headline
to this list to see if this is already being addressed?
"""

On Saturday, September 1, 2018, Linus Torvalds <
torvalds@linux-foundation.org> wrote:

> On Fri, Aug 31, 2018 at 12:45 AM Julian Stecklina <jsteckli@amazon.de>
> wrote:
> >
> > I've been spending some cycles on the XPFO patch set this week. For the
> > patch set as it was posted for v4.13, the performance overhead of
> > compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almost
> > completely from TLB flushing. If we can live with stale TLB entries
> > allowing temporary access (which I think is reasonable), we can remove
> > all TLB flushing (on x86). This reduces the overhead to 2-3% for
> > kernel compile.
>
> I have to say, even 2-3% for a kernel compile sounds absolutely horrendous.
>
> Kernel bullds are 90% user space at least for me, so a 2-3% slowdown
> from a kernel is not some small unnoticeable thing.
>
>            Linus
>

--00000000000054a9830574d6e505
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Speaking of pages and slowdowns,<div>is there a better place to ask this qu=
estion:</div><div><br></div><div>From &quot;&#39;Turning Tables&#39; shared=
 page tables vuln&quot;:</div><div><br></div><div>&quot;&quot;&quot;</div><=
div><div>&#39;New &quot;Turning Tables&quot; Technique Bypasses All Windows=
 Kernel Mitigations&#39;</div><div><a href=3D"https://www.bleepingcomputer.=
com/news/security/new-turning-tables-technique-bypasses-all-windows-kernel-=
mitigations/">https://www.bleepingcomputer.com/news/security/new-turning-ta=
bles-technique-bypasses-all-windows-kernel-mitigations/</a></div><div><br><=
/div><div>&gt; Furthermore, since the concept of page tables is also used b=
y Apple and the Linux project, macOS and Linux are, in theory, also vulnera=
ble to this technique, albeit the researchers have not verified such attack=
s, as of yet.</div><div><br></div><div>Slides: <a href=3D"https://cdn2.hubs=
pot.net/hubfs/487909/Turning%20(Page)%20Tables_Slides.pdf">https://cdn2.hub=
spot.net/hubfs/487909/Turning%20(Page)%20Tables_Slides.pdf</a></div><div><b=
r></div><div>Naturally, I took notice and decided to forward the latest sca=
ry headline to this list to see if this is already being addressed?</div><d=
iv>&quot;&quot;&quot;</div><br>On Saturday, September 1, 2018, Linus Torval=
ds &lt;<a href=3D"mailto:torvalds@linux-foundation.org">torvalds@linux-foun=
dation.org</a>&gt; wrote:<br><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Fri, Aug 31,=
 2018 at 12:45 AM Julian Stecklina &lt;<a href=3D"mailto:jsteckli@amazon.de=
">jsteckli@amazon.de</a>&gt; wrote:<br>
&gt;<br>
&gt; I&#39;ve been spending some cycles on the XPFO patch set this week. Fo=
r the<br>
&gt; patch set as it was posted for v4.13, the performance overhead of<br>
&gt; compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almo=
st<br>
&gt; completely from TLB flushing. If we can live with stale TLB entries<br=
>
&gt; allowing temporary access (which I think is reasonable), we can remove=
<br>
&gt; all TLB flushing (on x86). This reduces the overhead to 2-3% for<br>
&gt; kernel compile.<br>
<br>
I have to say, even 2-3% for a kernel compile sounds absolutely horrendous.=
<br>
<br>
Kernel bullds are 90% user space at least for me, so a 2-3% slowdown<br>
from a kernel is not some small unnoticeable thing.<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linus<br>
</blockquote></div>

--00000000000054a9830574d6e505--
