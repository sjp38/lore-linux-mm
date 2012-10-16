Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 778126B005D
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:21:13 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so7039284pbb.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 11:21:12 -0700 (PDT)
Date: Tue, 16 Oct 2012 23:51:08 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: [PATCH 3/5] Remove file_ra_state from arguments of
 count_history_pages.
Message-ID: <20121016182108.GE2826@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <e7275bef84867156b343ea3d558c4f669d1bc8b9.1348309711.git.rprabhu@wnohang.net>
 <20120922124028.GA15962@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6v9BRtpmy+umdQlo"
Content-Disposition: inline
In-Reply-To: <20120922124028.GA15962@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org


--6v9BRtpmy+umdQlo
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Sat, Sep 22, 2012 at 08:40:28PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>On Sat, Sep 22, 2012 at 04:03:12PM +0530, raghu.prabhu13@gmail.com wrote:
>> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>>
>> count_history_pages doesn't require readahead state to calculate the off=
set from history.
>>
>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>
>Acked-by: Fengguang Wu <fengguang.wu@intel.com>
>

Good. Do I need do anything else to get this into mm-tree? Few months=20
back, I had sent and few were acked, but they didn't end up=20
anywhere.




Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--6v9BRtpmy+umdQlo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQfaWUAAoJEKYW3KHXK+l3GgAH/jQj32BSS4ygyllM/YewqA53
6+w21xN84/T8cGOqjnl5X9MKE3giNETfDz69w/nqNNA5iWxxOzWwL1y2/JaKoYf6
UGUtjXfVjIGtPJQlnO/8ysCO1k/n/nxvvLfX2gWRr4L12LU9zN7w3FHgtJdG4xKx
50OMhlLPHvJKZwcVMIzdcKAXOTsd0zTHpKBxTgE+iELM78DsBdIzT/ZcIP+z+oq6
YJX20ubb143eI/3tEiGwEKXwD3knoGOylX/prGAxy4EyB7BrQmoCUcn74IY/zseJ
foRYqpC0drFmqOo504F9qiA8ccB7cD7iyg5gXwlH9TmMvwbde4xqxkvoUFEV/7A=
=irJ9
-----END PGP SIGNATURE-----

--6v9BRtpmy+umdQlo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
