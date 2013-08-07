Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C3C166B003C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 19:48:18 -0400 (EDT)
Subject: Re: [PATCH] aoe: adjust ref of head for compound page tails
MIME-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset="us-ascii"
From: Ed Cashin <ecashin@coraid.com>
In-Reply-To: <3F0FBDD9-129C-45F4-A20C-3EB2E8EFC9C8@coraid.com>
Date: Wed, 7 Aug 2013 19:48:15 -0400
Content-Transfer-Encoding: quoted-printable
Message-ID: <B5AF5A8D-2849-4027-A524-BA31BBCF8C8F@coraid.com>
References: <cover.1375320764.git.ecashin@coraid.com> <0c8aff39249c1da6b9cc3356650149d065c3ebd2.1375320764.git.ecashin@coraid.com> <20130807135804.e62b75f6986e9568ab787562@linux-foundation.org> <8DFEA276-4EE1-44B4-9669-5634631D7BBC@coraid.com> <20130807141835.533816143f8b37175c50d58d@linux-foundation.org> <20130807142755.5cd89e02e4286f7dca88b80d@linux-foundation.org> <3F0FBDD9-129C-45F4-A20C-3EB2E8EFC9C8@coraid.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org


On Aug 7, 2013, at 7:41 PM, Ed Cashin wrote:

> It sounds like it's wrong to give block pages with a zero count, so =
why not just have aoe BUG_ON(compound_trans_head(bv->page->_count) =3D=3D =
0) until we're sure nobody does that anymore?

Ugh.  I goofed the parens and such.  I meant,

  BUG_ON(compound_trans_head(bv->bv_page)->_count =3D=3D 0)

... will catch the cases we think should not be occurring.

> If that idea makes sense to you, I will submit a new patch to follow =
the one under discussion.

--=20
  Ed Cashin
  ecashin@coraid.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
