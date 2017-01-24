Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9A46B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 19:17:57 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so29534330wjb.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:17:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j26si20622270wrc.16.2017.01.23.16.17.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 16:17:56 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Tue, 24 Jan 2017 11:16:50 +1100
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <1485212994.3722.1.camel@primarydata.com>
References: <20170110160224.GC6179@noname.redhat.com> <87k2a2ig2c.fsf@notabene.neil.brown.name> <20170113110959.GA4981@noname.redhat.com> <20170113142154.iycjjhjujqt5u2ab@thunk.org> <20170113160022.GC4981@noname.redhat.com> <87mveufvbu.fsf@notabene.neil.brown.name> <1484568855.2719.3.camel@poochiereds.net> <87o9yyemud.fsf@notabene.neil.brown.name> <1485127917.5321.1.camel@poochiereds.net> <20170123002158.xe7r7us2buc37ybq@thunk.org> <20170123100941.GA5745@noname.redhat.com> <1485210957.2786.19.camel@poochiereds.net> <1485212994.3722.1.camel@primarydata.com>
Message-ID: <878tq1ia6l.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trondmy@primarydata.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "tytso@mit.edu" <tytso@mit.edu>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 23 2017, Trond Myklebust wrote:

> On Mon, 2017-01-23 at 17:35 -0500, Jeff Layton wrote:
>> On Mon, 2017-01-23 at 11:09 +0100, Kevin Wolf wrote:
>> >=20
>> > However, if we look at the greater problem of hanging requests that
>> > came
>> > up in the more recent emails of this thread, it is only moved
>> > rather
>> > than solved. Chances are that already write() would hang now
>> > instead of
>> > only fsync(), but we still have a hard time dealing with this.
>> >=20
>>=20
>> Well, it _is_ better with O_DIRECT as you can usually at least break
>> out
>> of the I/O with SIGKILL.
>>=20
>> When I last looked at this, the problem with buffered I/O was that
>> you
>> often end up waiting on page bits to clear (usually PG_writeback or
>> PG_dirty), in non-killable sleeps for the most part.
>>=20
>> Maybe the fix here is as simple as changing that?
>
> At the risk of kicking off another O_PONIES discussion: Add an
> open(O_TIMEOUT) flag that would let the kernel know that the
> application is prepared to handle timeouts from operations such as
> read(), write() and fsync(), then add an ioctl() or syscall to allow
> said application to set the timeout value.

I was thinking on very similar lines, though I'd use 'fcntl()' if
possible because it would be a per-"file description" option.
This would be a function of the page cache, and a filesystem wouldn't
need to know about it at all.  Once enable, 'read', 'write', or 'fsync'
would return EWOULDBLOCK rather than waiting indefinitely.
It might be nice if 'select' could then be used on page-cache file
descriptors, but I think that is much harder.  Support O_TIMEOUT would
be a practical first step - if someone agreed to actually try to use it.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliGnPIACgkQOeye3VZi
gbkExg/8CgpDhJWdCAO5dmqdPNSMaDd+fbQ3Rgr0tG17R7MzOlCIsvSAH5OrD76x
jQ1oro4ZJVLbcyQ96CvXKXf2mxKWcQzTd1Y/QomRzl7yxdYCuhOKxHpe0RZQCTcn
KS2sNBSthCrHx3WKnIxis2WfckQlTvZuobhHQHO3Ux3/IMMWMd/MU1SdFyxkxZyw
LifFwHRsLWjO44INKtF6m8CCNfPKB9kW4bUDd7bc9UIkejqa9PREJPxZ0SFE5e4f
Qz6valsdYiTIPpMVQ+7SFIsvyV8hWEO4CX24TlTX2SYQv64lJ99ECY0EbVLEuUo7
p8olN88jxtc+JwRSA26zE5dzIaj/Aelq2WSvMiX9DY42ANjKS9Mx2ODlPPiWY4tM
q+Y0NMXViA1qzFfKHwXLMSS2lAa5dp7jqnvFfhWXct6ffCFD+irFsnab8mJ4erCg
DdbNu4nYjh07F8d13Rm30uwuFxe0xogf4YySK8PQvoykZ6fNfYpOnvUNPqitOED5
rkjWX3dO2ZbBaX/IxSsF7QfynepK3es4/bOEST75YWU2NexyCZ4FYQUbfkb0BCAy
ztWbPshGZsRQ0sNtHOe6RDkMoYp3QWAU9i8KxamggkkOJ7w1ylF4wnWxZa6f4RWy
njWznpcYShA4QBskLqV5FLtuBahLa/WBhX8crF3tuvYZ/oEYxL8=
=ozsD
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
