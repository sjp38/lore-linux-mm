Date: Tue, 16 May 2006 13:24:22 +0200 (CEST)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH] mm: cleanup swap unused warning
In-Reply-To: <200605102132.41217.kernel@kolivas.org>
Message-ID: <Pine.LNX.4.64.0605161322110.17704@scrub.home>
References: <200605102132.41217.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811837-1682810690-1147778662=:17704"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

---1463811837-1682810690-1147778662=:17704
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hi,

On Wed, 10 May 2006, Con Kolivas wrote:

> Are there any users of swp_entry_t when CONFIG_SWAP is not defined?
>=20
> This patch fixes a warning for !CONFIG_SWAP for me.
>=20
> ---
> if CONFIG_SWAP is not defined we get:
>=20
> mm/vmscan.c: In function =E2=80=98remove_mapping=E2=80=99:
> mm/vmscan.c:387: warning: unused variable =E2=80=98swap=E2=80=99

In similiar cases (e.g. spinlocks) we usually do something like this:

#define swap_free(swp)=09((void)(swp))

bye, Roman
---1463811837-1682810690-1147778662=:17704--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
