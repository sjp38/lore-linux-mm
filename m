Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id E4A346B0039
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 13:48:05 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id ij19so8055763vcb.39
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:48:05 -0700 (PDT)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id ak16si6549950vdc.93.2014.07.18.10.48.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 10:48:05 -0700 (PDT)
Received: by mail-vc0-f176.google.com with SMTP id id10so3336873vcb.7
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:48:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1407141818590.8808@chino.kir.corp.google.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
	<20140711082956.GC20603@laptop.programming.kicks-ass.net>
	<20140711153314.GA6155@kroah.com>
	<alpine.LRH.2.00.1407120039120.17906@twin.jikos.cz>
	<alpine.DEB.2.02.1407141818590.8808@chino.kir.corp.google.com>
Date: Fri, 18 Jul 2014 10:48:04 -0700
Message-ID: <CAOhV88O9TnucGqmW_MbTwhBMmr8dwCfkFQDSP=GD3QSdeqF6Dw@mail.gmail.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
From: Nish Aravamudan <nish.aravamudan@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c22fb401c56804fe7b5c75
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jiri Kosina <jkosina@suse.cz>, Greg KH <gregkh@linuxfoundation.org>, Jiang Liu <jiang.liu@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-hotplug@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--001a11c22fb401c56804fe7b5c75
Content-Type: text/plain; charset=UTF-8

Hi David,

On Mon, Jul 14, 2014 at 6:19 PM, David Rientjes <rientjes@google.com> wrote:
>
> On Sat, 12 Jul 2014, Jiri Kosina wrote:
>
> > I am pretty sure I've seen ppc64 machine with memoryless NUMA node.
> >
>
> Yes, Nishanth Aravamudan (now cc'd) has been working diligently on the
> problems that have been encountered, including problems in generic kernel
> code, on powerpc with memoryless nodes.

Thanks for Cc'ing me on this discussion. I'm going to review Jiang's
patchset now, as best I can, but yes I can confirm we see memoryless nodes
somewhat frequently on powerpc under PowerVM, due to presumably hypervisor
fragmentation (the reason isn't clear to an LPAR, as it's just given a
topology).

I agree with Dave Hansen that this seems like a "good thing" to try and
figure out, unless KVM decides it's going to hide the underlying topology
of a guest's memory from the guest -- which I think could lead (eventually)
to confusing performance results.

I believe I have also seen them in hardware on ia64 (cpu-only and
memory-only drawers), but not sure if those specific models are in
production still.

Finally, I will say that in working on supporting memoryless nodes, I've
come across what look like bugs in the NUMA code. Or more accurately,
assumptions which aren't always true. So it's a useful exercise for that
reason to.

Thanks,
Nish

--001a11c22fb401c56804fe7b5c75
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi David,<br><br>On Mon, Jul 14, 2014 at 6:19 PM, David Ri=
entjes &lt;<a href=3D"mailto:rientjes@google.com">rientjes@google.com</a>&g=
t; wrote:<br>&gt;<br>&gt; On Sat, 12 Jul 2014, Jiri Kosina wrote:<br>&gt;<b=
r>
&gt; &gt; I am pretty sure I&#39;ve seen ppc64 machine with memoryless NUMA=
 node.<br>&gt; &gt;<br>&gt;<br>&gt; Yes, Nishanth Aravamudan (now cc&#39;d)=
 has been working diligently on the<br>&gt; problems that have been encount=
ered, including problems in generic kernel<br>
&gt; code, on powerpc with memoryless nodes.<br><br>Thanks for Cc&#39;ing m=
e on this discussion. I&#39;m going to review Jiang&#39;s patchset now, as =
best I can, but yes I can confirm we see memoryless nodes somewhat frequent=
ly on powerpc under PowerVM, due to presumably hypervisor fragmentation (th=
e reason isn&#39;t clear to an LPAR, as it&#39;s just given a topology).<br=
>
<br>I agree with Dave Hansen that this seems like a &quot;good thing&quot; =
to try and figure out, unless KVM decides it&#39;s going to hide the underl=
ying topology of a guest&#39;s memory from the guest -- which I think could=
 lead (eventually) to confusing performance results.<br>
<br>I believe I have also seen them in hardware on ia64 (cpu-only and memor=
y-only drawers), but not sure if those specific models are in production st=
ill.<br><br>Finally, I will say that in working on supporting memoryless no=
des, I&#39;ve come across what look like bugs in the NUMA code. Or more acc=
urately, assumptions which aren&#39;t always true. So it&#39;s a useful exe=
rcise for that reason to.<br>
<br>Thanks,<br>Nish</div>

--001a11c22fb401c56804fe7b5c75--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
