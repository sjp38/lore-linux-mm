Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA896B0055
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 02:51:44 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1H7o3FD021719
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 00:50:03 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1H7pgsQ213568
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 00:51:42 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1H7pfWj022716
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 00:51:42 -0700
Message-ID: <499A6C7C.9060106@linux.vnet.ibm.com>
Date: Tue, 17 Feb 2009 01:51:24 -0600
From: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 7/8] ecryptfs: use kzfree()
References: <20090216142926.440561506@cmpxchg.org> <20090216144726.088020837@cmpxchg.org>
In-Reply-To: <20090216144726.088020837@cmpxchg.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig82585C0BC219E1CC4686197B"
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig82585C0BC219E1CC4686197B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Johannes Weiner wrote:
> Use kzfree() instead of memset() + kfree().
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tyler Hicks <tyhicks@linux.vnet.ibm.com>

Acked-by: Tyler Hicks <tyhicks@linux.vnet.ibm.com>

Thanks for kzfree() and the updates to eCryptfs - I will put it to use
in the future.

> ---
>  fs/ecryptfs/keystore.c  |    3 +--
>  fs/ecryptfs/messaging.c |    3 +--
>  2 files changed, 2 insertions(+), 4 deletions(-)
>=20
> --- a/fs/ecryptfs/keystore.c
> +++ b/fs/ecryptfs/keystore.c
> @@ -740,8 +740,7 @@ ecryptfs_write_tag_70_packet(char *dest,
>  out_release_free_unlock:
>  	crypto_free_hash(s->hash_desc.tfm);
>  out_free_unlock:
> -	memset(s->block_aligned_filename, 0, s->block_aligned_filename_size);=

> -	kfree(s->block_aligned_filename);
> +	kzfree(s->block_aligned_filename);
>  out_unlock:
>  	mutex_unlock(s->tfm_mutex);
>  out:
> --- a/fs/ecryptfs/messaging.c
> +++ b/fs/ecryptfs/messaging.c
> @@ -291,8 +291,7 @@ int ecryptfs_exorcise_daemon(struct ecry
>  	if (daemon->user_ns)
>  		put_user_ns(daemon->user_ns);
>  	mutex_unlock(&daemon->mux);
> -	memset(daemon, 0, sizeof(*daemon));
> -	kfree(daemon);
> +	kzfree(daemon);
>  out:
>  	return rc;
>  }
>=20
>=20



--------------enig82585C0BC219E1CC4686197B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAkmabIIACgkQqDCb9l015QLPyACcCSOVkzCRUeBe3Jc1N0Cfxxf0
CZ8AnA+6FD4jFxDuGQGfrrQuzDb+9Zko
=8FHV
-----END PGP SIGNATURE-----

--------------enig82585C0BC219E1CC4686197B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
