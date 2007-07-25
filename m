Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: Your message of "Wed, 25 Jul 2007 07:30:37 +0200."
             <46A6DFFD.9030202@gmail.com>
From: Valdis.Kletnieks@vt.edu
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <200707102015.44004.kernel@kolivas.org> <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
            <46A6DFFD.9030202@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1185347660_3413P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 25 Jul 2007 03:14:20 -0400
Message-ID: <30701.1185347660@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1185347660_3413P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <30677.1185347635.1@turing-police.cc.vt.edu>

On Wed, 25 Jul 2007 07:30:37 +0200, Rene Herman said:

> Yes, but what's locate's usage scenario? I've never, ever wanted to use it. 
> When do you know the name of something but not where it's located, other 
> than situations which "which" wouldn't cover and after just having 
> installed/unpacked something meaning locate doesn't know about it yet either?

My favorite use - with 5 Fedora kernels and as many -mm kernels on my laptop,
doing a 'locate moby' finds all the moby.c and moby.o and moby.ko for
the various releases. For bonus points, something like:

ls -lt `locate iwl3945.ko`

to find all 19 copies that are on my system, and remind me which ones were
compiled when.  Or just when you remember the name of some one-off 100-line
Perl program that you wrote 6 months ago, but not sure which directory you
left it in... ;)

You want hard numbers? Here you go - 'locate' versus 'find'
(/usr/src/ has about 290K files on it):

%  strace locate iwl3945.ko  >| /tmp/foo3 2>&1
% wc /tmp/foo3
  96  592 6252 /tmp/foo3
% strace find /usr/src /lib -name iwl3945.ko >| /tmp/foo4 2>&1
% wc /tmp/foo4
  328380  1550032 15708205 /tmp/foo4

# echo 1 > /proc/sys/vm/drop_caches     (to empty the caches

% time locate iwl3945.ko > /dev/null

real    0m0.872s
user    0m0.867s
sys     0m0.008s

% time find /usr/src /lib -name iwl3945.ko > /dev/null
find: /usr/src/lost+found: Permission denied

real    1m12.241s
user    0m1.128s
sys     0m3.566s

So 96 system calls in 1 second, against 328K calls in a minute.  There's your
use case, right there.  Now if we can just find a way for that find/updatedb
to not be as painful to the rest of the system.....





--==_Exmh_1185347660_3413P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGpvhMcC3lWbTT17ARApzIAKDeWs0+L/41cIMa80MBkaM7fEdMKwCgimtj
Mfu/czdM6pdPQMmynnE381I=
=uMEx
-----END PGP SIGNATURE-----

--==_Exmh_1185347660_3413P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
