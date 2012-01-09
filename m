Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 0EA576B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 04:31:14 -0500 (EST)
Message-ID: <1326101456.2442.40.camel@twins>
Subject: Re: [PATCH v6 0/8] Reduce cross CPU IPI interference
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 09 Jan 2012 10:30:56 +0100
In-Reply-To: <1326040026-7285-1-git-send-email-gilad@benyossef.com>
References: <y> <1326040026-7285-1-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>

On Sun, 2012-01-08 at 18:26 +0200, Gilad Ben-Yossef wrote:
> Still, kernel code will some time interrupt all CPUs in the system via IP=
Is
> for various needs. These IPIs are useful and cannot be avoided altogether=
,
> but in certain cases it is possible to interrupt only specific CPUs that
> have useful work to do and not the entire system.=20

1-7

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
