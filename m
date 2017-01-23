Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87BFF6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:34:41 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t18so20237372wmt.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 11:34:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c21si19896041wrc.301.2017.01.23.11.34.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 11:34:40 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Tue, 24 Jan 2017 06:34:29 +1100
Subject: Re: [ATTEND] many topics
In-Reply-To: <20170123170924.ubx2honzxe7g34on@thunk.org>
References: <20170118054945.GD18349@bombadil.infradead.org> <20170118133243.GB7021@dhcp22.suse.cz> <20170119110513.GA22816@bombadil.infradead.org> <20170119113317.GO30786@dhcp22.suse.cz> <20170119115243.GB22816@bombadil.infradead.org> <20170119121135.GR30786@dhcp22.suse.cz> <878tq5ff0i.fsf@notabene.neil.brown.name> <20170121131644.zupuk44p5jyzu5c5@thunk.org> <87ziijem9e.fsf@notabene.neil.brown.name> <20170123060544.GA12833@bombadil.infradead.org> <20170123170924.ubx2honzxe7g34on@thunk.org>
Message-ID: <87mvehd0ze.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 24 2017, Theodore Ts'o wrote:

> On Sun, Jan 22, 2017 at 10:05:44PM -0800, Matthew Wilcox wrote:
>>=20
>> I don't have a clear picture in my mind of when Java promotes objects
>> from nursery to tenure
>
> It's typically on the order of minutes.   :-)
>
>> ... which is not too different from my lack of
>> understanding of what the MM layer considers "temporary" :-)  Is it
>> acceptable usage to allocate a SCSI command (guaranteed to be freed
>> within 30 seconds) from the temporary area?  Or should it only be used
>> for allocations where the thread of control is not going to sleep between
>> allocation and freeing?
>
> What the mm folks have said is that it's to prevent fragmentation.  If
> that's the optimization, whether or not you the process is allocating
> the memory sleeps for a few hundred milliseconds, or even seconds, is
> really in the noise compared with the average lifetime of an inode in
> the inode cache, or a page in the page cache....
>
> Why do you think it matters whether or not we sleep?  I've not heard
> any explanation for the assumption for why this might be important.

Because "TEMPORARY" implies a limit to the amount of time, and sleeping
is the thing that causes a process to take a large amount of time.  It
seems like an obvious connection to me.

Imagine I want to allocate a large contiguous region in the
ZONE_MOVEABLE region.  I find a mostly free region, so I just need to
move those last few pages.  If there is a limit on how long a process
can sleep while holding an allocation from ZONE_MOVEABLE, then I know
how long, at most, I need to wait before those pages become either free
or movable.  If those processes can wait indefinitely, then I might have
to wait indefinitely to get this large region.

"temporary" doesn't mean anything without a well defined time limit.

But maybe I completely misunderstand.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliGWsUACgkQOeye3VZi
gbn9ZA/+MTyGNbc3PBlEghUaTikfII4EMfa5w7AGULQLSZKvKplTPrTJwc+QmSY8
sNZI4WPGwL3Gw68xDWXb8pN8X1Zcg2+dvuAFCJyolgsQjL/1FrxN8eSgcvBMNXBC
m28YDeY+xOIofLW5q2IK9XS2nAwCcezoLKe79gzXchVonKx+/H6+emB0icRTmq64
TUAyKk26q+YdWe1Y9AoCPZqKLXt/EH0/s8S1PRZV3oxoZdzcsjvOpxMgOzJbAi3v
9CHTCsOCvqnBfiVhIVG9iagHUZoeQcDa9C2nQ5jE9tNhxsPvhVl4kWW9+cFIWKw4
AbxeeDkuuascspNyi/C1vnYmIl01H1sLRBsVrbhP1CifqolDZqQTBM8C/isb7Hde
vaGjckiokW/Uq1yN1gf5ViZqUMHxI8/C+aN38+Yvi0p4/6CYCzl7yghGSPydYINE
CC4+OavCnMKQIldl39vltntxTkyJyhDZUSq7iWoQLuCtLei3zdRRWAhwLe/kGvoh
zNjFg8Z8Tw2/lCNDIh41b/J33uI3l0KhqJM1jxDpXI/eXp/JWy0ADm6merggoHda
K4ro7c4yd35HNxixvSRPZe4BhyDchCRTDEiiAr4aHmrWkH7Bkcf/YbVQuAqcfYEt
7jdFPRQ2E/J4Ne2r6mFSq8BagpQHvfzttvAqKdbD+uix8ZDhfBc=
=tCJC
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
