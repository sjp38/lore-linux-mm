Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 3EA8C6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 13:47:11 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so3851344dad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 10:47:10 -0700 (PDT)
Date: Tue, 16 Oct 2012 23:17:05 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: Re: [PATCH 1/5] mm/readahead: Check return value of
 read_pages
Message-ID: <20121016174705.GC2826@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <dcdfd8620ae632321a28112f5074cc3c78d05bde.1348309711.git.rprabhu@wnohang.net>
 <20120922124337.GA17562@localhost>
 <20120926012503.GA24218@Archie>
 <20120928115405.GA1525@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IMjqdzrDRly81ofr"
Content-Disposition: inline
In-Reply-To: <20120928115405.GA1525@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org


--IMjqdzrDRly81ofr
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Fri, Sep 28, 2012 at 07:54:05PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>On Wed, Sep 26, 2012 at 06:55:03AM +0530, Raghavendra D Prabhu wrote:
>>
>> Hi,
>>
>>
>> * On Sat, Sep 22, 2012 at 08:43:37PM +0800, Fengguang Wu <fengguang.wu@i=
ntel.com> wrote:
>> >On Sat, Sep 22, 2012 at 04:03:10PM +0530, raghu.prabhu13@gmail.com wrot=
e:
>> >>From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> >>
>> >>Return value of a_ops->readpage will be propagated to return value of =
read_pages
>> >>and __do_page_cache_readahead.
>> >
>> >That does not explain the intention and benefit of this patch..
>>
>> I noticed that force_page_cache_readahead checks return value of
>> __do_page_cache_readahead but the actual error if any is never
>> propagated.
>
>force_page_cache_readahead()'s return value, in turn, is never used by
>its callers..
Yes, it is not called by its callers, however, since it is called=20
in a loop, shouldn't we bail out if force_page_cache_readahead=20
fails once? Without the appropriate return value, it will=20
continue  and  in=20

force_page_cache_readahead


		if (err < 0) {
			ret =3D err;
			break;
		}

	is never hit.
Nor does the other __do_page_cache_readahead() callers
>care about the error state. So until we find an actual user of the
>error code, I'd recommend to avoid changing the current code.
>
>Thanks,
>Fengguang
>




Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--IMjqdzrDRly81ofr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQfZ2ZAAoJEKYW3KHXK+l3BI0H/2VNkvjgy/bDvjBiKK4CVZLH
61A+s6TVd4Por2P5YvusOt4v9QU+zF6A9XgGQ4Vtss5cqDDg+q1l105ujyeR+tVS
ynXpgxAAanGCSMndQDsp0HPRpWOhiaIpsv6b1AFwYLRUQNtOBU4RsdvFu+UudiQw
wb+T+Y0PZCnOa7PUqZayXsuQpj2pfTP/od8uQuJod3Py46p8vXH8SqmYlMMaZDi8
tAaMBYE7fIDPFJa8V03z6L8U5RDNrrFcBsfjjEdS4Aek6bjUbU5tesmWcYzpNEj5
+VLwh6isT5S0InfAHA6+5iLCzEp2Ngh5dCxvEO9jopZehP7Uw0r+SLdgjQpqLp4=
=Ucuh
-----END PGP SIGNATURE-----

--IMjqdzrDRly81ofr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
