Date: Thu, 31 Jul 2003 19:15:02 +0800
From: Eugene Teo <eugene.teo@eugeneteo.net>
Subject: Understanding page faults code in mm/memory.c
Message-ID: <20030731111502.GA1591@eugeneteo.net>
Reply-To: Eugene Teo <eugene.teo@eugeneteo.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi there,

With reference to 2.4.20, I have a few questions:

[1] I was looking at mm/memory.c. I noticed that there is a=20
difference between minor, and major faults. My guess is that
when a major fault occurs, the mm performs a page-in from the
swap to the memory, whilst a minor fault doesn't? No?

[2] I understand that for the handle_pte_fault routine, the
if structure basically handles page-in. I am trying to figure
out where I can find the code for page-out which I understand
it can be involved the swap, etc. Can someone give me some
pointers as to where I can look for:

    - what causes page-outs,
    - where in the kernel can i look for them?

[3] in mm/memory.c, in do_wp_page, I am not sure what the
portion of code is about:

// If old_page bit is not set, set it, and test.
if (!TryLockPage(old_page) {

    // [QN:] I don't understand what can_share_swap_page() do
    // I tried tracing, but i still don't quite get it.
    int reuse =3D can_share_swap_page(old_page);   =20
    unlock_page(old_page);
    if (reuse) {
        // flush the old mapping out of the tlb.
        fluse_cache_page(vma, address);
       =20
        // creates a new mapping with entry in the page table       =20
        // [QN:] What is pte_mkyoung?
        establish_pte(vma, address, page_table, pte_mkyoung(...
       =20
        spin_unlock(&mm->page_table_lock);

        // [QN:] why didn't the mm->rss increased since it is
        // a minor fault? hmm, i am not sure what minor
        // fault is though.
        return 1; /* minor fault */
    }
}   =20

Hear from you guys. Thank you so much.

Cheers,
Eugene
(posted this in another mailing list before)


--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/KPo2cyGjihSg3eURAh6sAJ9PSWHkYlfOpuKOSboQxjzMZSOPsACfS1Go
y57DZvniymurvSiqiJCH2TI=
=w03B
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
