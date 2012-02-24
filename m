Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C6E066B00EB
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 05:05:28 -0500 (EST)
Received: by obbta7 with SMTP id ta7so3428830obb.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 02:05:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1202240200380.24971@chino.kir.corp.google.com>
References: <20120222115320.GA3107@x61.redhat.com>
	<alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com>
	<20120223152226.GA2014@x61.redhat.com>
	<alpine.DEB.2.00.1202231509510.26362@chino.kir.corp.google.com>
	<alpine.LFD.2.02.1202240856370.1917@tux.localdomain>
	<alpine.DEB.2.00.1202240200380.24971@chino.kir.corp.google.com>
Date: Fri, 24 Feb 2012 12:05:27 +0200
Message-ID: <CAOJsxLExoyzvpRNOEdT3+x1mhSCZt0dO7NLKkpi7CrJ7HW2kpw@mail.gmail.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Fri, Feb 24, 2012 at 12:03 PM, David Rientjes <rientjes@google.com> wrot=
e:
> I like how slub handles this when it can't allocate more slab with
> slab_out_of_memory() and has the added benefit of still warning even with
> __GFP_NORETRY that the oom killer is never called for. =A0If there's real=
ly
> a slab leak happening, there's a good chance that this diagnostic
> information is going to be emitted by the offending cache at some point i=
n
> time if you're using slub. =A0This could easily be extended to slab.c, so
> it's even more reason not to include this type of information in the oom
> killer.

Works for me. Rafael?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
