From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 2/2] mm: Initialize error in shmem_file_aio_read()
Date: Sun, 13 Apr 2014 21:50:29 +0100
Message-ID: <20140413205029.GO18016@ZenIV.linux.org.uk>
References: <1397414783-28098-1-git-send-email-geert@linux-m68k.org>
 <1397414783-28098-2-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1397414783-28098-2-git-send-email-geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: linux-mm.kvack.org

On Sun, Apr 13, 2014 at 08:46:22PM +0200, Geert Uytterhoeven wrote:
> mm/shmem.c: In function =E2=80=98shmem_file_aio_read=E2=80=99:
> mm/shmem.c:1414: warning: =E2=80=98error=E2=80=99 may be used uniniti=
alized in this function
>=20
> If the loop is aborted during the first iteration by one of the two f=
irst
> break statements, error will be uninitialized.
>=20
> Introduced by commit 6e58e79db8a16222b31fc8da1ca2ac2dccfc4237
> ("introduce copy_page_to_iter, kill loop over iovec in
> generic_file_aio_read()").
>=20
> Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
> ---
> The code is too complex to see if this is an obvious false positive.

Good catch; sadly, it *can* be triggered - read() starting past the EOF
will step into it.  Applied, will push today.
