Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 4510F6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:15:26 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so7034422pbb.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 11:15:26 -0700 (PDT)
Date: Tue, 16 Oct 2012 23:45:21 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: [PATCH 4/5] Move the check for ra_pages after
 VM_SequentialReadHint()
Message-ID: <20121016181521.GD2826@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <b3c8b02fb273826f864f64d4588b36758fde2b5d.1348309711.git.rprabhu@wnohang.net>
 <20120922124250.GB15962@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3XA6nns4nE4KvaS/"
Content-Disposition: inline
In-Reply-To: <20120922124250.GB15962@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org


--3XA6nns4nE4KvaS/
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Sat, Sep 22, 2012 at 08:42:50PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>it.rprabhu@wnohang.net>
>User-Agent: Mutt/1.5.21 (2010-09-15)
>X-Date: Sat Sep 22 18:12:50 IST 2012
>
>On Sat, Sep 22, 2012 at 04:03:13PM +0530, raghu.prabhu13@gmail.com wrote:
>> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>>
>> page_cache_sync_readahead checks for ra->ra_pages again, so moving the c=
heck
>> after VM_SequentialReadHint.
>
>Well it depends on what case you are optimizing for. I suspect there
>are much more tmpfs users than VM_SequentialReadHint users. So this
>change is actually not desirable wrt the more widely used cases.

shm/tmpfs doesn't use this function for fault. They have=20
shmem_fault for that.  So, that shouldn't matter here. Agree?

>
>Thanks,
>Fengguang
>
>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> ---
>>  mm/filemap.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index 3843445..606a648 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -1523,8 +1523,6 @@ static void do_sync_mmap_readahead(struct vm_area_=
struct *vma,
>>  	/* If we don't want any read-ahead, don't bother */
>>  	if (VM_RandomReadHint(vma))
>>  		return;
>> -	if (!ra->ra_pages)
>> -		return;
>>
>>  	if (VM_SequentialReadHint(vma)) {
>>  		page_cache_sync_readahead(mapping, ra, file, offset,
>> @@ -1532,6 +1530,9 @@ static void do_sync_mmap_readahead(struct vm_area_=
struct *vma,
>>  		return;
>>  	}
>>
>> +	if (!ra->ra_pages)
>> +		return;
>> +
>>  	/* Avoid banging the cache line if not needed */
>>  	if (ra->mmap_miss < MMAP_LOTSAMISS * 10)
>>  		ra->mmap_miss++;
>> --
>> 1.7.12.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see




Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--3XA6nns4nE4KvaS/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQfaQ5AAoJEKYW3KHXK+l3WdIH/AsbGhhz5J+WnmqOcD9iaDYe
ohu78dr4vgOBgLKxuT4Nwe1oLY9r7vaNTylFCy9lrrgjz3n8Jo7qCI+Q2fDROMvy
xOMWf3ZhQXE6Ulfjed0mWuxq1hQ6O5qvdNU3kuWHf7LbPRX7Epxijnzp3I/1TSVb
aXkMRv9jQGEG2YxUzmo2mOEpT3l9J8f6FL4YUFjNKfYCt/QOaww5FOmCgtfSwwvn
o53fm4mj3k64XTfHX8puivoKnIbL+SjjLXaNgRV93CZyuAx8umkMjHllM/4J2+5O
WI2WIwxe5x+irvclEa85HfzUWrCo5Kgc0c2L4TdJrBeVgEt5ngTCNGxi7ZPzABk=
=+2t2
-----END PGP SIGNATURE-----

--3XA6nns4nE4KvaS/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
