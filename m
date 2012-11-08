Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 1CBC06B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 12:13:04 -0500 (EST)
Date: Thu, 8 Nov 2012 19:14:22 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 1/3] mm: Add VM pressure notifications
Message-ID: <20121108171421.GA4824@shutemov.name>
References: <20121107105348.GA25549@lizard>
 <20121107110128.GA30462@lizard>
 <20121108170124.GB8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20121108170124.GB8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Thu, Nov 08, 2012 at 05:01:24PM +0000, Mel Gorman wrote:
> (Sorry about being very late reviewing this)
>=20
> On Wed, Nov 07, 2012 at 03:01:28AM -0800, Anton Vorontsov wrote:
> > This patch introduces vmpressure_fd() system call. The system call crea=
tes
> > a new file descriptor that can be used to monitor Linux' virtual memory
> > management pressure. There are three discrete levels of the pressure:
> >=20
>=20
> Why was eventfd unsuitable? It's a bit trickier to use but there are
> examples in the kernel where an application is required to do something l=
ike
>=20
> 1. open eventfd
> 2. open a control file, say /proc/sys/vm/vmpressure or if cgroups
>    /sys/fs/cgroup/something/vmpressure
> 3. write fd_event fd_control [low|medium|oom]. Can be a binary structure
>    you write
>=20
> and then poll the eventfd. The trickiness is awkward but a library
> implementation of vmpressure_fd() that mapped onto eventfd properly should
> be trivial.
>=20
> I confess I'm not super familiar with eventfd and if this can actually
> work in practice

You've described how it works for memory thresholds and oom notifications
in memcg. So it works. I also prefer this kind of interface.

See Documentation/cgroups/cgroups.txt section 2.4 and
Documentation/cgroups/memory.txt sections 9 and 10.

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
