Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D240F6B007B
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:44:36 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1628353pbb.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 13:44:36 -0700 (PDT)
Date: Thu, 25 Oct 2012 02:14:07 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re: [PATCH] Change the check for PageReadahead into an else-if
Message-ID: <20121024204407.GA3218@Archie>
References: <08589dd39c78346ec2ed2fedfd6e3121ca38acda.1350413420.git.rprabhu@wnohang.net>
 <20121017020012.GA13769@localhost>
 <CAHGf_=qxMv20bNg2FZLCO2Ra0S+zTicxQEXu=nOTc-f3kiWj-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mYCpIKhGyMATD0i+"
Content-Disposition: inline
In-Reply-To: <CAHGf_=qxMv20bNg2FZLCO2Ra0S+zTicxQEXu=nOTc-f3kiWj-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, zheng.yan@oracle.com, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Tue, Oct 16, 2012 at 10:02:44PM -0400, KOSAKI Motohiro <kosaki.motohir=
o@gmail.com> wrote:
>On Tue, Oct 16, 2012 at 10:00 PM, Fengguang Wu <fengguang.wu@intel.com> wr=
ote:
>> On Wed, Oct 17, 2012 at 12:28:05AM +0530, raghu.prabhu13@gmail.com wrote:
>>> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>>>
>>> >From 51daa88ebd8e0d437289f589af29d4b39379ea76, page_sync_readahead coa=
lesces
>>> async readahead into its readahead window, so another checking for that=
 again is
>>> not required.
>>>
>>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>>> ---
>>>  fs/btrfs/relocation.c | 10 ++++------
>>>  mm/filemap.c          |  3 +--
>>>  2 files changed, 5 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
>>> index 4da0865..6362003 100644
>>
>>> --- a/fs/btrfs/relocation.c
>>> +++ b/fs/btrfs/relocation.c
>>> @@ -2996,12 +2996,10 @@ static int relocate_file_extent_cluster(struct =
inode *inode,
>>>                               ret =3D -ENOMEM;
>>>                               goto out;
>>>                       }
>>> -             }
>>> -
>>> -             if (PageReadahead(page)) {
>>> -                     page_cache_async_readahead(inode->i_mapping,
>>> -                                                ra, NULL, page, index,
>>> -                                                last_index + 1 - index=
);
>>> +             } else if (PageReadahead(page)) {
>>> +                             page_cache_async_readahead(inode->i_mappi=
ng,
>>> +                                                     ra, NULL, page, i=
ndex,
>>> +                                                     last_index + 1 - =
index);
>>
>> That extra indent is not necessary.
>>
>> Otherwise looks good to me. Thanks!
>>
>> Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>
>
>Hi Raghavendra,
>
>Indentation breakage is now welcome. Please respin it. Otherwise
>
>Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks, will do.


Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--mYCpIKhGyMATD0i+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQiFMXAAoJEKYW3KHXK+l3UdEIAMgbpM2D4fp6BmjHQEgFyRdX
W5tJ1pV3tvBiaiHUAqvh/fjuKE1vnVPXDCfjrF/UB3itfjCVaBMShNNSWQbMEYYX
PZ7zCsxeUFjXTCQQIU4oxEGfzidsMUp80N+3/v0lpMd1E6aJsWCHNTyCrWdbfdBi
cIy4sMszX6TAJRoEcCASDTEjISTgkh/wVvM4UfgHZdnMsIPSHLOD+SXjmXEgLn9w
udrfZi436E1tOQOQFYiJpmpWGXTD374K1FwVTW6hJ7AJlxo7QsHq2cqp211DRnDo
zGPxYmtcVse0q6Yk4fQV5IKaSQb6BfrPzwo0c7lFIBtCnuxugE3iRTKFIyosx7M=
=Atud
-----END PGP SIGNATURE-----

--mYCpIKhGyMATD0i+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
