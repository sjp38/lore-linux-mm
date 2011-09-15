Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E44A09000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 13:30:25 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <075c4e4c-a22d-47d1-ae98-31839df6e722@default>
Date: Thu, 15 Sep 2011 10:29:51 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org
 4E72284B.2040907@linux.vnet.ibm.com>
In-Reply-To: <4E72284B.2040907@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
>=20
> Hey Nitin,
>=20
> So this is how I see things...
>=20
> Right now xvmalloc is broken for zcache's application because
> of its huge fragmentation for half the valid allocation sizes
> (> PAGE_SIZE/2).

Um, I have to disagree here. It is broken for zcache for
SOME set of workloads/data, where the AVERAGE compression
is poor (> PAGE_SIZE/2).
=20
> My xcfmalloc patches are _a_ solution that is ready now.  Sure,
> it doesn't so compaction yet, and it has some metadata overhead.
> So it's not "ideal" (if there is such I thing). But it does fix
> the brokenness of xvmalloc for zcache's application.

But at what cost?  As Dave Hansen pointed out, we still do
not have a comprehensive worst-case performance analysis for
xcfmalloc.  Without that (and without an analysis over a very
large set of workloads), it is difficult to characterize
one as "better" than the other.

> So I see two ways going forward:
>=20
> 1) We review and integrate xcfmalloc now.  Then, when you are
> done with your allocator, we can run them side by side and see
> which is better by numbers.  If yours is better, you'll get no
> argument from me and we can replace xcfmalloc with yours.
>=20
> 2) We can agree on a date (sooner rather than later) by which your
> allocator will be completed.  At that time we can compare them and
> integrate the best one by the numbers.
>=20
> Which would you like to do?

Seth, I am still not clear why it is not possible to support
either allocation algorithm, selectable at runtime.  Or even
dynamically... use xvmalloc to store well-compressible pages
and xcfmalloc for poorly-compressible pages.  I understand
it might require some additional coding, perhaps even an
ugly hack or two, but it seems possible.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
