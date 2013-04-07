Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id AABDD6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 13:52:08 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <62e1fe34-e5be-42f5-83af-f8f428fce57b@default>
Date: Sun, 7 Apr 2013 10:51:27 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages
 more efficiently
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130407090341.GA22589@hacker.(null)>
In-Reply-To: <20130407090341.GA22589@hacker.(null)>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Bob Liu <bob.liu@oracle.com>, Ric Mason <ric.masonn@gmail.com>

> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> Subject: Re: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pa=
ges more efficiently
>=20
> Hi Dan,
>=20
> Some issues against Ramster:
>=20
> - Ramster who takes advantage of zcache also should support zero-filled
>   pages more efficiently, correct? It doesn't handle zero-filled pages we=
ll
>   currently.

When you first posted your patchset I took a quick look at ramster
and it looked like your patchset should work for ramster also.
However I didn't actually run ramster to try it so there may
be a bug.  If it doesn't work, I would very much appreciate a patch.

> - Ramster DebugFS counters are exported in /sys/kernel/mm/, but zcache/fr=
ontswap/cleancache
>   all are exported in /sys/kernel/debug/, should we unify them?

That would be great.

> - If ramster also should move DebugFS counters to a single file like
>   zcache do?

Sure!  I am concerned about Konrad's patches adding debug.c as they
add many global variables.  They are only required when ZCACHE_DEBUG
is enabled so they may be ok.  If not, adding ramster variables
to debug.c may make the problem worse.

> If you confirm these issues are make sense to fix, I will start coding. ;=
-)

That would be great.  Note that I have a how-to for ramster here:

https://oss.oracle.com/projects/tmem/dist/files/RAMster/HOWTO-120817=20

If when you are testing you find that this how-to has mistakes,
please let me know.  Or feel free to add the (corrected) how-to file
as a patch in your patchset.

Thanks very much, Wanpeng, for your great contributions!

(Ric, since you have expressed interest in ramster, if you try it and
find corrections to the how-to file above, your input would be
very much appreciated also!)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
