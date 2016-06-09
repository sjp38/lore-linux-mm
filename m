Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA1B36B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 03:51:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so50789697pfs.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 00:51:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id z76si6334280pfa.43.2016.06.09.00.51.55
        for <linux-mm@kvack.org>;
        Thu, 09 Jun 2016 00:51:55 -0700 (PDT)
From: Felipe Balbi <balbi@kernel.org>
Subject: Re: [PATCH 00/21] Delete CURRENT_TIME and CURRENT_TIME_SEC macros
In-Reply-To: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
Date: Thu, 09 Jun 2016 10:51:31 +0300
Message-ID: <87twh294vw.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Deepa Dinamani <deepa.kernel@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, y2038@lists.linaro.org, Anna Schumaker <anna.schumaker@netapp.com>, Anton Vorontsov <anton@enomsg.org>, Benny Halevy <bhalevy@primarydata.com>, Boaz Harrosh <ooo@electrozaur.com>, Changman Lee <cm224.lee@samsung.com>, Chris Mason <clm@fb.com>, Colin Cross <ccross@android.com>, Dave Kleikamp <shaggy@kernel.org>, "David S. Miller" <davem@davemloft.net>, David Sterba <dsterba@suse.com>, Eric Van Hensbergen <ericvh@gmail.com>, Hugh Dickins <hughd@google.com>, Ian Kent <raven@themaw.net>, Jaegeuk Kim <jaegeuk@kernel.org>, Joern Engel <joern@logfs.org>, Josef Bacik <jbacik@fb.com>, Kees Cook <keescook@chromium.org>, Latchesar Ionkov <lucho@ionkov.net>, Matt Fleming <matt@codeblueprint.co.uk>, Matthew Garrett <matthew.garrett@nebula.com>, Miklos Szeredi <miklos@szeredi.hu>, Nadia Yvette Chambers <nyc@holomorphy.com>, Prasad Joshi <prasadjoshi.linux@gmail.com>, Robert Richter <rric@kernel.org>, Ron Minnich <rminnich@sandia.gov>, Tony Luck <tony.luck@intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, autofs@vger.kernel.org, cluster-devel@redhat.com, jfs-discussion@lists.sourceforge.net, linux-btrfs@vger.kernel.org, linux-efi@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-security-module@vger.kernel.org, linux-usb@vger.kernel.org, logfs@logfs.org, netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com, oprofile-list@lists.sf.net, osd-dev@open-osd.org, selinux@tycho.nsa.gov, v9fs-developer@lists.sourceforge.net

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi,

Deepa Dinamani <deepa.kernel@gmail.com> writes:
>  drivers/usb/gadget/function/f_fs.c                 |  2 +-
>  drivers/usb/gadget/legacy/inode.c                  |  2 +-

for drivers/usb/gadget:

Acked-by: Felipe Balbi <balbi@kernel.org>

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXWSADAAoJEIaOsuA1yqRE3xkP/iQ1fuTIybbV6wTI8KcBipLN
RYE+b6JJVPFMIpj76aDznk/eZG+CSnwRUAPoPGWs1o7xVqnVGqfLDMWyHLp3pU5C
NQyphaTDahzkV3cbTbAjbLpcluDKmCmRb++9YyfSyEcFP4HnlpgmIVFM7SinMADk
OXGwum3/L0HpAs+91j4FORMHiKma5fa5CXmE5aHsM3TSWONWldycLywu9jlF/AyU
lY83J4AjvL2qii9hWdlxX81+zFZ92Vh9v5vvms8ErPB2w3a75PbM70gaoVM2VOxQ
kMeLZUiGywrnDv+/RKC+9WX3KiwDsAlTk1rbuDBePE7PbjQmRW/hfRtXcpECXAyG
LrV9HskF1UIIv8aVyWoR/GwQdO0cdxoW8uBuw+/l7pSHTvfpvl3/sb+VNBH3j2lQ
aosxpF7QlU08QxWzpPHgrQ7TNbZ0o9zl5aZ8HAhAPt9FZDu1KKHy/EEJ0aI5d25y
p7aTdxvf2SxMGVo6K1ozZUq/EeXOW061oeOUmDLT1NZWS69g19lGBx/XSWLpqf1b
V6SK0hpP3QqHajNOsTFfHLuP13zygCZsSQJU1Z4MO3RyawyMsgjCqAKrEHCoF0zL
rCfYHY+r6PMRmrirPoBdPwdoWB8/i1INydBfU4OqjO/7dRgjhl2iPSUvSOPrhVlu
g2HkIFwp1Wj8eyUm+JYM
=tfo4
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
