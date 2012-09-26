Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id AA3116B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 21:29:06 -0400 (EDT)
Received: by dadi14 with SMTP id i14so17379dad.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 18:29:05 -0700 (PDT)
Date: Wed, 26 Sep 2012 06:59:00 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: [PATCH 2/5] mm/readahead: Change the condition for
 SetPageReadahead
Message-ID: <20120926012900.GA36532@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <82b88a97e1b86b718fe8e4616820d224f6abbc52.1348309711.git.rprabhu@wnohang.net>
 <20120922124920.GB17562@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
In-Reply-To: <20120922124920.GB17562@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Sat, Sep 22, 2012 at 08:49:20PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>On Sat, Sep 22, 2012 at 04:03:11PM +0530, raghu.prabhu13@gmail.com wrote:
>> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>>
>> If page lookup from radix_tree_lookup is successful and its index page_i=
dx =3D=3D
>> nr_to_read - lookahead_size, then SetPageReadahead never gets called, so=
 this
>> fixes that.
>
>NAK. Sorry. It's actually an intentional behavior, so that for the
>common cases of many cached files that are accessed frequently, no
>PG_readahead will be set at all to pointlessly trap into the readahead
>routines once and again.

ACK, thanks for explaining that. However, regarding this, I would=20
like to know if the implications of the patch=20
51daa88ebd8e0d437289f589af29d4b39379ea76 will still apply if=20
PG_readahead is not set.

>
>Perhaps we need a patch for commenting that case. :)
>
>Thanks,
>Fengguang
>
>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> ---
>>  mm/readahead.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/readahead.c b/mm/readahead.c
>> index 461fcc0..fec726c 100644
>> --- a/mm/readahead.c
>> +++ b/mm/readahead.c
>> @@ -189,8 +189,10 @@ __do_page_cache_readahead(struct address_space *map=
ping, struct file *filp,
>>  			break;
>>  		page->index =3D page_offset;
>>  		list_add(&page->lru, &page_pool);
>> -		if (page_idx =3D=3D nr_to_read - lookahead_size)
>> +		if (page_idx >=3D nr_to_read - lookahead_size) {
>>  			SetPageReadahead(page);
>> +			lookahead_size =3D 0;
>> +		}
>>  		ret++;
>>  	}
>>
>> --
>> 1.7.12.1
>




Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQYlpcAAoJEKYW3KHXK+l3uawH/2MqtofboTsqzui/XgjdoIEv
RgeWU3Y1w7eOIajtCm28F0m7KG/LM4smwOWXk3VqqxNoGkiQ8CaYrj2f2uM7VIHA
BM5Pmz+LuJr/PpN3gFukWzDEA2w4b4q/cqqodVuD3f3BjcQYLVzrjGWOTC7UncER
2wYPH3VvAjQHEN/IQYEBQrbezuzcBKWxS/9c4x4y2sX173QY4NkKlsEYbJLFseZ6
N0NDuEVdPv4sxmyh1WFh1Ozht8No+vttsS+P+NCTxfde4bMG0Ikp6Rwekjv+nLzX
h+i+Y/5Htzm+nEswjKqwdPglRviQY9+7mXiND/bXWwW+ZDm+sbJRZhTXO/cConE=
=5Qp4
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
