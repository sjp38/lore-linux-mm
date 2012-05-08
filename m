Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 7432F6B0083
	for <linux-mm@kvack.org>; Tue,  8 May 2012 11:47:48 -0400 (EDT)
Received: by yhr47 with SMTP id 47so7885432yhr.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 08:47:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANudz+uVSGiYUQcaCj95qxc9_shv4YKWmN=X+U3ca+a0CWRiEA@mail.gmail.com>
References: <CANudz+uVSGiYUQcaCj95qxc9_shv4YKWmN=X+U3ca+a0CWRiEA@mail.gmail.com>
Date: Tue, 8 May 2012 23:47:47 +0800
Message-ID: <CANudz+uh701RL4-k_chOgjN8Nr4EaZJH4nfQ=+HC4NkYFW16fA@mail.gmail.com>
Subject: Some questions about boot memory
From: loody <miloody@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

hi all:

=A0I have some question about the relationship between page table
=A0creation and bootmemery allocation.
=A0bootmemory allocation use 1-bit to declare this page is used or not.
=A0Does that mean when a new page table is creating, it will reference
=A0the bits of bootmap and add dirty flag on the page of the page table cre=
ated?

=A0--
=A0Thanks a lot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
