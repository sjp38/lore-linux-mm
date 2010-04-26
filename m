Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BEB776B0204
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 08:47:07 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f038ee35-8b34-4305-b93a-49383c86f83e@default>
Date: Mon, 26 Apr 2010 05:45:57 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
 <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
 <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default>
 <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
 <4BD1B427.9010905@redhat.com> <b559c57a-0acb-4338-af21-dbfc3b3c0de5@default>
 <4BD336CF.1000103@redhat.com> <d1bb78ca-5ef6-4a8d-af79-a265f2d4339c@default>
 <4BD43182.1040508@redhat.com> <c5062f3a-3232-4b21-b032-2ee1f2485ff0@default>
 <4BD44E74.2020506@redhat.com> <7264e3c0-15fe-4b70-a3d8-2c36a2b934df@default
 4BD52C4F.40505@redhat.com>
In-Reply-To: <4BD52C4F.40505@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> dma engines are present on commodity hardware now:
>=20
> http://en.wikipedia.org/wiki/I/O_Acceleration_Technology
>=20
> I don't know if consumer machines have them, but servers certainly do.
> modprobe ioatdma.

They don't seem to have gained much ground in the FIVE YEARS
since the patch was first posted to Linux, have they?

Maybe it's because memory-to-memory copy using a CPU
is so fast (especially for page-ish quantities of data)
and is a small percentage of CPU utilization these days?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
