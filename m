Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 9BFFF6B00EF
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 13:25:41 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <331d4603-ac1e-40a5-b581-c18becf3ae9a@default>
Date: Wed, 4 Apr 2012 10:25:33 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap feedback from LSF/MM and patches
References: <4F7C7DA6.8000406@linux.vnet.ibm.com>
In-Reply-To: <4F7C7DA6.8000406@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Frontswap feedback from LSF/MM and patches
>=20
> Dan,
>=20
> I know you presented at LSF/MM.  I was wondering if you'd could
> give a quick summary of any feedback you received regarding frontswap,
> for those of us that were not there.

Hi Seth (and all) --

The feedback on frontswap was much more encouraging this
time, but the bottom line was re-post them and people would
take another look.

Andrea was much more supportive with writethrough as an
option because he believes it will greatly improve the
stability and usability for zcache in a KVM host.  He
was also pleased with a zcache policy change for clean
pages, but that doesn't (directly) affect frontswap.

Rik was much more supportive, and akpm said he would
take another look.  I didn't get a chance to talk to
James Bottomley as to whether he was satisfied with
the latest zcache benchmarking (the lack of which was
the core of his frontswap objections).

I think the MM community is now starting to understand
how all the transcendent memory parts fit together,
that the sum of the parts has some good value and
potential, and that frontswap is a critical piece
in the tmem ecosystem.

But we'll see when it is re-posted.... ;-)

> Konard,
>=20
> Can you post the latest frontswap patches to the list since the
> last post was v10 back in Sept 2011
> (https://lkml.org/lkml/2011/9/15/367) and those patches no longer
> apply cleanly.  I know you have them in your git repo, but
> I think they need to be on the list too.

While I agree a re-post is necessary, Konrad has ensured
the most recent frontswap is in linux-next so, by definition,
applies cleanly to 3.4-rc1.

Konrad, I'd like to add a small change to optionally enable
writethrough (and am traveling so won't get to that until next
week).  I also think we should seriously consider rolling
in the module support changes from Erlangen University before
posting another frontswap version to lkml/linux-mm.

But, yes, I am much more encouraged that frontswap will
have a good chance of being merged for the next window (3.5),
so let's ensure we get it re-posted soon to incorporate
community feedback in plenty of time before the next window.

Whether zcache should be promoted for the same window or should
wait another cycle is a decision I will leave to Konrad and
Greg and/or any other affected maintainers.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
