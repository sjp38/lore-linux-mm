Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 7E9106B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 04:36:47 -0500 (EST)
Received: by eekc13 with SMTP id c13so134532eek.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 01:36:45 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v8 0/8] Reduce cross CPU IPI interference
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
Date: Wed, 08 Feb 2012 10:36:42 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9cszgo23l0zgt@mpn-glaptop>
In-Reply-To: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi
 Kivity <avi@redhat.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Sun, 05 Feb 2012 14:33:20 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:
> This patch set, inspired by discussions with Peter Zijlstra and Freder=
ic
> Weisbecker when testing the nohz task patch set, is a first stab at tr=
ying
> to explore doing this by locating the places where such global IPI cal=
ls
> are being made and turning the global IPI into an IPI for a specific g=
roup
> of CPUs.  The purpose of the patch set is to get feedback if this is t=
he
> right way to go for dealing with this issue and indeed, if the issue i=
s
> even worth dealing with at all. Based on the feedback from this patch =
set
> I plan to offer further patches that address similar issue in other co=
de
> paths.
>
> The patch creates an on_each_cpu_mask and on_each_cpu_cond infrastruct=
ure
> API (the former derived from existing arch specific versions in Tile a=
nd
> Arm) and uses them to turn several global IPI invocation to per CPU
> group invocations.

> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Christoph Lameter <cl@linux.com>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> CC: linux-mm@kvack.org
> CC: Pekka Enberg <penberg@kernel.org>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Sasha Levin <levinsasha928@gmail.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Andi Kleen <andi@firstfloor.org>
> CC: Mel Gorman <mel@csn.ul.ie>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Alexander Viro <viro@zeniv.linux.org.uk>
> CC: Avi Kivity <avi@redhat.com>
> CC: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

for patches form 1 to 4 and 7.  The other two (5 and 6) look good but
I don't know enough about slub and fs to feel confident acking.

> CC: Kosaki Motohiro <kosaki.motohiro@gmail.com>
> CC: Milton Miller <miltonm@bga.com>

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
