Message-ID: <3DB5A2E6.6000305@redhat.com>
Date: Tue, 22 Oct 2002 12:11:34 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
References: <Pine.LNX.4.44L.0210221514430.1648-100000@duckman.distro.conecti va> <145460000.1035311809@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44L.0210221514430.1648-100000@duckman.distro.conecti va>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@digeo.com>, "Eric W. Biederman" <ebiederm@xmission.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Dave McCracken wrote:

>   3) The current large page implementation is only for applications
>      that want anonymous *non-pageable* shared memory.  Shared page
>      tables reduce resource usage for any shared area that's mapped
>      at a common address and is large enough to span entire pte pages.


Does this happen automatically (i.e., without modifying th emmap call)?

In any case, a system using prelinking will likely have all users of a
DSO mapping the DSO at the same address.  Will a system benefit in this
case?  If not directly, perhaps with some help from ld.so since we do
know when we expect the same is used everywhere.

- -- 
- --------------.                        ,-.            444 Castro Street
Ulrich Drepper \    ,-----------------'   \ Mountain View, CA 94041 USA
Red Hat         `--' drepper at redhat.com `---------------------------
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE9taLn2ijCOnn/RHQRAgJ6AJ9AzHCX3NrpZPpGUF9XIQYPdX2NPQCgw7BP
6fIfDzEvsxbGvVtoUX76aAw=
=LKpP
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
