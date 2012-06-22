Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 227376B0179
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 10:14:44 -0400 (EDT)
Message-ID: <1340374439.18025.75.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 22 Jun 2012 16:13:59 +0200
In-Reply-To: <4FE47D0E.3000804@redhat.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	  <1340315835-28571-2-git-send-email-riel@surriel.com>
	 <1340359115.18025.57.camel@twins> <4FE47D0E.3000804@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On Fri, 2012-06-22 at 10:11 -0400, Rik van Riel wrote:
>=20
> I am still trying to wrap my brain around your alternative
> search algorithm, not sure if/how it can be combined with
> arbitrary address limits and alignment...=20

for alignment we can do: len +=3D align - 1;

Will indeed need to ponder the range thing ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
