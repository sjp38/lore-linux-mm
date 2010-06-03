Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00BCA6B01AC
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 00:55:46 -0400 (EDT)
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <andreas.dilger@oracle.com>
In-Reply-To: <4C07179F.5080106@vflare.org>
Date: Wed, 2 Jun 2010 22:53:44 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <3721BEE2-DF2D-452A-8F01-E690E32C6B33@oracle.com>
References: <20100528173510.GA12166%ca-server1.us.oracle.comAANLkTilV-4_QaNq5O0WSplDx1Oq7JvkgVrEiR1rgf1up@mail.gmail.com> <489aa002-6d42-4dd5-bb66-81c665f8cdd1@default> <4C07179F.5080106@vflare.org>
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan.kim@gmail.com>, chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On 2010-06-02, at 20:46, Nitin Gupta wrote:
> On 06/03/2010 04:32 AM, Dan Magenheimer wrote:
>>> From: Minchan Kim [mailto:minchan.kim@gmail.com]
>>=20
>>>> I am also eagerly awaiting Nitin Gupta's cleancache backend
>>>> and implementation to do in-kernel page cache compression.
>>>=20
>>> Do Nitin say he will make backend of cleancache for
>>> page cache compression?
>>>=20
>>> It would be good feature.
>>> I have a interest, too. :)
>>=20
>> That was Nitin's plan for his GSOC project when we last discussed
>> this.  Nitin is on the cc list and can comment if this has
>> changed.
>=20
> Yes, I have just started work on in-kernel page cache compression
> backend for cleancache :)

Is there a design doc for this implementation?  I was thinking it would =
be quite clever to do compression in, say, 64kB or 128kB chunks in a =
mapping (to get decent compression) and then write these compressed =
chunks directly from the page cache to disk in btrfs and/or a revived =
compressed ext4.

That would mean that the on-disk compression algorithm needs to match =
the in-memory algorithm, which implies that the in-memory compression =
algorithm should be selectable on a per-mapping basis.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
