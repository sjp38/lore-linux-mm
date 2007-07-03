Date: Tue, 3 Jul 2007 18:29:58 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Sparc32: random invalid instruction occourances on sparc32 (sun4c)
In-Reply-To: <468A7D14.1050505@googlemail.com>
Message-ID: <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
References: <468A7D14.1050505@googlemail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1750305931-300674694-1183483798=:29930"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, reiserfs-devel@vger.kernel.org, "Vladimir V. Saveliev" <vs@namesys.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-ide@vger.kernel.org, David Chinner <dgc@sgi.com>, linux-mm@kvack.org, sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>, Mikael Pettersson <mikpe@it.uu.se>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

--1750305931-300674694-1183483798=:29930
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hi all,

I think I have found the cause of the problem.

Commit b46b8f19c9cd435ecac4d9d12b39d78c137ecd66 partially fixed alignment=
=20
issues but does not ensure that all 64bit alignment requirements of=20
sparc32 are met. Tests have shown that the redzone2 word can become=20
misallignd.

I am currently working on a posible fix.

Regards
 =09Mark Fortescue.

On Tue, 3 Jul 2007, Michal Piotrowski wrote:

> Hi all,
>
> Here is a list of some known regressions in 2.6.22-rc7.
>
> Feel free to add new regressions/remove fixed etc.
> http://kernelnewbies.org/known_regressions
>
> List of Aces
>
> Name                    Regressions fixed since 21-Jun-2007
> Hugh Dickins                           2
> Andi Kleen                             1
> Andrew Morton                          1
> Benjamin Herrenschmidt                 1
> Bj=F6rn Steinbrink                       1
> Bjorn Helgaas                          1
> Jean Delvare                           1
> Olaf Hering                            1
> Siddha, Suresh B                       1
> Trent Piepho                           1
> Ville Syrj=E4l=E4                          1
>
>
>
> FS
>
> Subject    : 2.6.22-rc4-git5 reiserfs: null ptr deref.
> References : http://lkml.org/lkml/2007/6/13/322
> Submitter  : Randy Dunlap <randy.dunlap@oracle.com>
> Handled-By : Vladimir V. Saveliev <vs@namesys.com>
> Status     : problem is being debugged
>
>
>
> IDE
>
> Subject    : 2.6.22-rcX: hda: lost interrupt
> References : http://lkml.org/lkml/2007/6/29/121
> Submitter  : David Chinner <dgc@sgi.com>
> Status     : unknown
>
>
>
> Sparc64
>
> Subject    : random invalid instruction occourances on sparc32 (sun4c)
> References : http://lkml.org/lkml/2007/6/17/111
> Submitter  : Mark Fortescue <mark@mtfhpc.demon.co.uk>
> Status     : problem is being debugged
>
> Subject    : 2.6.22-rc broke X on Ultra5
> References : http://lkml.org/lkml/2007/5/22/78
> Submitter  : Mikael Pettersson <mikpe@it.uu.se>
> Handled-By : David Miller <davem@davemloft.net>
> Status     : problem is being debugged
>
>
>
> Regards,
> Michal
>
> --
> LOG
> http://www.stardust.webpages.pl/log/
> -
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
--1750305931-300674694-1183483798=:29930--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
