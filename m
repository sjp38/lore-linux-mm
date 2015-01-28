Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0A06B0032
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 07:36:25 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so20526987wes.10
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 04:36:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si8437002wjo.59.2015.01.28.04.36.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 04:36:23 -0800 (PST)
Message-ID: <54C8D7B0.7030803@redhat.com>
Date: Wed, 28 Jan 2015 07:36:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: OOM at low page cache?
References: <54C2C89C.8080002@gmail.com> <54C77086.7090505@suse.cz> <20150128062609.GA4706@blaptop>
In-Reply-To: <20150128062609.GA4706@blaptop>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: John Moser <john.r.moser@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/28/2015 01:26 AM, Minchan Kim wrote:
> Hello,
> 
> On Tue, Jan 27, 2015 at 12:03:34PM +0100, Vlastimil Babka wrote:
>> CC linux-mm in case somebody has a good answer but missed this in
>> lkml traffic
>> 
>> On 01/23/2015 11:18 PM, John Moser wrote:
>>> Why is there no tunable to OOM at low page cache?
> 
> AFAIR, there were several trial although there wasn't acceptable at
> that time. One thing I can remember is min_filelist_kbytes. FYI,
> http://lwn.net/Articles/412313/

The Android low memory killer does exactly what you want, and
for very much the same reasons.

See drivers/staging/android/lowmemorykiller.c

However, in the mainline kernel I think it does make sense to
apply something like the patch that Minchan cooked up with, to OOM
if freeing all the page cache could not bring us back up to the high
watermark, across all the memory zones.

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUyNewAAoJEM553pKExN6DlKQH/3PprrXF7IOyjiXnO+2Qqbau
wgWXO7mQWGFi+zNqSUzmWtfTCFVx6BxLi23MCQG1RqKGnQI4DehdOKMDidFwoC8D
2grKe9ELp04mEbyG0aipdxSw6FouIDFhC2FzmU7oQDZX5RKmLuxY7QPU4NTCitcR
xHp6jWrvyY2CDiSpA2QSAaAAIG21BtPJvXQg3WvY/LI03N1edqZnExt5Po8CY7oe
EeiO7ZtYISl/wRIoribEafZF4rMAfJ5A36kdbulqCqVtgCWEDPV0RCXimc5EtDIt
bFDiv924+YMiuEFULJlEqLGqTJOtfJ+NlBIn8nVRk5P1pOGEbO05zE+XV1Vea6k=
=8351
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
