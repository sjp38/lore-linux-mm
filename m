Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 52B4E6B0206
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 08:51:25 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2634f2cb-3e7e-4c86-b7ef-cf4a3f1e0d8a@default>
Date: Mon, 26 Apr 2010 05:50:26 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
 <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
 <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default>
 <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
 <4BD1B427.9010905@redhat.com> <4BD24E37.30204@vflare.org>
 <4BD33822.2000604@redhat.com> <4BD3B2D1.8080203@vflare.org>
 <4BD4329A.9010509@redhat.com> <4BD4684E.9040802@vflare.org
 4BD52D55.3070803@redhat.com>
In-Reply-To: <4BD52D55.3070803@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>, ngupta@vflare.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > Maybe incremental development is better? Stabilize and refine
> existing
> > code and gradually move to async API, if required in future?
>=20
> Incremental development is fine, especially for ramzswap where the APIs
> are all internal.  I'm more worried about external interfaces, these
> stick around a lot longer and if not done right they're a pain forever.

Well if you are saying that your primary objection to the
frontswap synchronous API is that it is exposed to modules via
some EXPORT_SYMBOLs, we can certainly fix that, at least
unless/until there are other pseudo-RAM devices that can use it.

Would that resolve your concerns?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
