Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 6B75B6B00F9
	for <linux-mm@kvack.org>; Fri,  4 May 2012 15:30:48 -0400 (EDT)
Date: Fri, 4 May 2012 15:24:59 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH] Expand memblock=debug to provide a bit more details
 (v1).
Message-ID: <20120504192459.GA5684@phenom.dumpdata.com>
References: <1336157382-14548-1-git-send-email-konrad.wilk@oracle.com>
 <CAE9FiQWOps3Hmw=p6mWObRnu2KHVNshpoY+uWcAAQd1Yxi54yQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <CAE9FiQWOps3Hmw=p6mWObRnu2KHVNshpoY+uWcAAQd1Yxi54yQ@mail.gmail.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: linux-kernel@vger.kernel.org, tj@kernel.org, hpa@linux.intel.com, paul.gortmaker@windriver.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, May 04, 2012 at 12:22:58PM -0700, Yinghai Lu wrote:
> On Fri, May 4, 2012 at 11:49 AM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com> wrote:
> > While trying to track down some memory allocation issues, I realized =
that
> > memblock=3Ddebug was giving some information, but for guests with 256=
GB or
> > so the majority of it was just:
> >
> > =A0memblock_reserve: [0x00003efeeea000-0x00003efeeeb000] __alloc_memo=
ry_core_early+0x5c/0x64
> >
> > which really didn't tell me that much. With these patches I know it i=
s:
> >
> > =A0memblock_reserve: [0x00003ffe724000-0x00003ffe725000] (4kB) vmemma=
p_pmd_populate+0x4b/0xa2
> >
> > .. which isn't really that useful for the problem I was tracking down=
, but
> > it does help in figuring out which routines are using memblock.
> >
>=20
> that RET_IP is not very helpful for debugging.

Is there a better way of doing it that is automatic?
>=20
> Actually I have local debug patch for memblock. please check if that
> is going to help debugging.
>=20
> Thanks
>=20
> Yinghai



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
