Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA836B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:20:28 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u98so5871531wrb.17
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:20:28 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id b18si11757364wrb.250.2017.11.22.14.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 14:20:26 -0800 (PST)
Date: Wed, 22 Nov 2017 23:20:25 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] mm: replace FSF address with web source in license
 notices
Message-ID: <20171122222025.GA3623@amd>
References: <20171114094438.28224-1-martink@posteo.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BXVAT5kNtrzKuDFl"
Content-Disposition: inline
In-Reply-To: <20171114094438.28224-1-martink@posteo.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Kepplinger <martink@posteo.de>
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2017-11-14 10:44:38, Martin Kepplinger wrote:
> A few years ago the FSF moved and "59 Temple Place" is wrong. Having this
> still in our source files feels old and unmaintained.
>=20
> Let's take the license statement serious and not confuse users.
>=20
> As https://www.gnu.org/licenses/gpl-howto.html suggests, we replace the
> postal address with "<http://www.gnu.org/licenses/>" in the mm directory.
>=20
> Signed-off-by: Martin Kepplinger <martink@posteo.de>
> ---
>  mm/kmemleak-test.c | 3 +--
>  mm/kmemleak.c      | 3 +--
>  2 files changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/mm/kmemleak-test.c b/mm/kmemleak-test.c
> index dd3c23a801b1..9a13ad2c0cca 100644
> --- a/mm/kmemleak-test.c
> +++ b/mm/kmemleak-test.c
> @@ -14,8 +14,7 @@
>   * GNU General Public License for more details.
>   *
>   * You should have received a copy of the GNU General Public License
> - * along with this program; if not, write to the Free Software
> - * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 U=
SA
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
>   */
> =20

With all the SPDX work, I don't think this is useful. Talk to Greg?

We do ship copy of GPL, so perhaps the paragraph can be just deleted?

If not, maybe it should be http_s_?
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--BXVAT5kNtrzKuDFl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAloV+CkACgkQMOfwapXb+vLfUgCdHX2qPf5x4V6TU6i5NFymL8Z1
aTUAoILnDIHTItGC8I0PDqaTXwx/5wNF
=DTKY
-----END PGP SIGNATURE-----

--BXVAT5kNtrzKuDFl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
