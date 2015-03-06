Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 779B96B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 10:40:37 -0500 (EST)
Received: by wibhm9 with SMTP id hm9so4459994wib.2
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 07:40:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a8si15716868wjs.28.2015.03.06.07.40.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Mar 2015 07:40:35 -0800 (PST)
Message-ID: <54F9CA32.3050407@redhat.com>
Date: Fri, 06 Mar 2015 08:39:30 -0700
From: Eric Blake <eblake@redhat.com>
MIME-Version: 1.0
Subject: Re: [Qemu-devel] [PATCH 02/21] userfaultfd: linux/Documentation/vm/userfaultfd.txt
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com> <1425575884-2574-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-3-git-send-email-aarcange@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="noF7tnHsD61G0LuwSVKVHrkMBnWhfn9Jv"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Jan Kara <jack@suse.cz>, Neil Brown <neilb@suse.de>, Stefan Hajnoczi <stefanha@gmail.com>, Andrew Jones <drjones@redhat.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Taras Glek <tglek@mozilla.com>, zhang.zhanghailiang@huawei.com, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Sasha Levin <sasha.levin@oracle.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andres Lagar-Cavilla <andreslc@google.com>, Christopher Covington <cov@codeaurora.org>, Anthony Liguori <anthony@codemonkey.ws>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Keith Packard <keithp@keithp.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Juan Quintela <quintela@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Hommey <mh@glandium.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--noF7tnHsD61G0LuwSVKVHrkMBnWhfn9Jv
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/05/2015 10:17 AM, Andrea Arcangeli wrote:
> Add documentation.
>=20
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  Documentation/vm/userfaultfd.txt | 97 ++++++++++++++++++++++++++++++++=
++++++++
>  1 file changed, 97 insertions(+)
>  create mode 100644 Documentation/vm/userfaultfd.txt

Just a grammar review (no analysis of technical correctness)

>=20
> diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfa=
ultfd.txt
> new file mode 100644
> index 0000000..2ec296c
> --- /dev/null
> +++ b/Documentation/vm/userfaultfd.txt
> @@ -0,0 +1,97 @@
> +=3D Userfaultfd =3D
> +
> +=3D=3D Objective =3D=3D
> +
> +Userfaults allow to implement on demand paging from userland and more

s/to implement/the implementation of/
and maybe: s/on demand/on-demand/

> +generally they allow userland to take control various memory page
> +faults, something otherwise only the kernel code could do.
> +
> +For example userfaults allows a proper and more optimal implementation=

> +of the PROT_NONE+SIGSEGV trick.
> +
> +=3D=3D Design =3D=3D
> +
> +Userfaults are delivered and resolved through the userfaultfd syscall.=

> +
> +The userfaultfd (aside from registering and unregistering virtual
> +memory ranges) provides for two primary functionalities:

s/provides for/provides/

> +
> +1) read/POLLIN protocol to notify an userland thread of the faults

s/an userland/a userland/ (remember, 'a unicorn gets an umbrella' - if
the 'u' is pronounced 'you' the correct article is 'a')

> +   happening
> +
> +2) various UFFDIO_* ioctls that can mangle over the virtual memory
> +   regions registered in the userfaultfd that allows userland to
> +   efficiently resolve the userfaults it receives via 1) or to mangle
> +   the virtual memory in the background

maybe: s/mangle/manage/2

> +
> +The real advantage of userfaults if compared to regular virtual memory=

> +management of mremap/mprotect is that the userfaults in all their
> +operations never involve heavyweight structures like vmas (in fact the=

> +userfaultfd runtime load never takes the mmap_sem for writing).
> +
> +Vmas are not suitable for page(or hugepage)-granular fault tracking

s/page(or hugepage)-granular/page- (or hugepage-) granular/

> +when dealing with virtual address spaces that could span
> +Terabytes. Too many vmas would be needed for that.
> +
> +The userfaultfd once opened by invoking the syscall, can also be
> +passed using unix domain sockets to a manager process, so the same
> +manager process could handle the userfaults of a multitude of
> +different process without them being aware about what is going on

s/process/processes/

> +(well of course unless they later try to use the userfaultfd themself

s/themself/themselves/

> +on the same region the manager is already tracking, which is a corner
> +case that would currently return -EBUSY).
> +
> +=3D=3D API =3D=3D
> +
> +When first opened the userfaultfd must be enabled invoking the
> +UFFDIO_API ioctl specifying an uffdio_api.api value set to UFFD_API

s/an uffdio/a uffdio/

> +which will specify the read/POLLIN protocol userland intends to speak
> +on the UFFD. The UFFDIO_API ioctl if successful (i.e. if the requested=

> +uffdio_api.api is spoken also by the running kernel), will return into=

> +uffdio_api.bits and uffdio_api.ioctls two 64bit bitmasks of
> +respectively the activated feature bits below PAGE_SHIFT in the
> +userfault addresses returned by read(2) and the generic ioctl
> +available.
> +
> +Once the userfaultfd has been enabled the UFFDIO_REGISTER ioctl should=

> +be invoked (if present in the returned uffdio_api.ioctls bitmask) to
> +register a memory range in the userfaultfd by setting the
> +uffdio_register structure accordingly. The uffdio_register.mode
> +bitmask will specify to the kernel which kind of faults to track for
> +the range (UFFDIO_REGISTER_MODE_MISSING would track missing
> +pages). The UFFDIO_REGISTER ioctl will return the
> +uffdio_register.ioctls bitmask of ioctls that are suitable to resolve
> +userfaults on the range reigstered. Not all ioctls will necessarily be=


s/reigstered/registered/

> +supported for all memory types depending on the underlying virtual
> +memory backend (anonymous memory vs tmpfs vs real filebacked
> +mappings).
> +
> +Userland can use the uffdio_register.ioctls to mangle the virtual

maybe s/mangle/manage/

> +address space in the background (to add or potentially also remove
> +memory from the userfaultfd registered range). This means an userfault=


s/an/a/

> +could be triggering just before userland maps in the background the
> +user-faulted page. To avoid POLLIN resulting in an unexpected blocking=

> +read (if the UFFD is not opened in nonblocking mode in the first
> +place), we don't allow the background thread to wake userfaults that
> +haven't been read by userland yet. If we would do that likely the
> +UFFDIO_WAKE ioctl could be dropped. This may change in the future
> +(with a UFFD_API protocol bumb combined with the removal of the

s/bumb/bump/

> +UFFDIO_WAKE ioctl) if it'll be demonstrated that it's a valid
> +optimization and worthy to force userland to use the UFFD always in
> +nonblocking mode if combined with POLLIN.
> +
> +userfaultfd is also a generic enough feature, that it allows KVM to
> +implement postcopy live migration (one form of memory externalization
> +consisting of a virtual machine running with part or all of its memory=

> +residing on a different node in the cloud) without having to modify a
> +single line of KVM kernel code. Guest async page faults, FOLL_NOWAIT
> +and all other GUP features works just fine in combination with
> +userfaults (userfaults trigger async page faults in the guest
> +scheduler so those guest processes that aren't waiting for userfaults
> +can keep running in the guest vcpus).
> +
> +The primary ioctl to resolve userfaults is UFFDIO_COPY. That
> +atomically copies a page into the userfault registered range and wakes=

> +up the blocked userfaults (unless uffdio_copy.mode &
> +UFFDIO_COPY_MODE_DONTWAKE is set). Other ioctl works similarly to
> +UFFDIO_COPY.
>=20
>=20
>=20

--=20
Eric Blake   eblake redhat com    +1-919-301-3266
Libvirt virtualization library http://libvirt.org


--noF7tnHsD61G0LuwSVKVHrkMBnWhfn9Jv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Public key at http://people.redhat.com/eblake/eblake.gpg
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBCAAGBQJU+coyAAoJEKeha0olJ0NqrXsIAILrBkZemsV+IvQTydQFd1vT
aQ0XfU5RHlHZ5YEunNWrHmOGJDkSlC+VKXq6FwGiLym3UwW66BGw8AX3hQQr3TKP
oUOoSWrmtwqy26zIP5dUJNQUkodfKBMxe0NISqRx6D55VkTSdThXGWlhzyjApgW6
lsnvoNQi68eWApIxiXO2m+qSpSfj27sVxhm6haQywKFbtRqIEb+jNKSp+EZB7DOr
eCbfgztTgPC2VPpraMWYDRi6DFHCBd4k+f+xt3CqTKADgN4FRBVj0sL2razi3Dw5
1s21Db3zFEiNVWc18273YZALkjAU1ZYMW3fHzb4aXOR/TweFuIZYFjCGsrdFsgg=
=VRG0
-----END PGP SIGNATURE-----

--noF7tnHsD61G0LuwSVKVHrkMBnWhfn9Jv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
