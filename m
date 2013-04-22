Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 04BAA6B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 08:19:11 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id r3so6269675wey.17
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 05:19:10 -0700 (PDT)
Subject: Re: page eviction from the buddy cache
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <51730619.3030204@fastmail.fm>
Date: Mon, 22 Apr 2013 15:18:59 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <51874517-8D82-433E-9E10-13167C736D5F@gmail.com>
References: <51504A40.6020604@ya.ru> <20130327150743.GC14900@thunk.org> <alpine.LNX.2.00.1303271135420.29687@eggly.anvils> <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com> <515CD665.9000300@gmail.com> <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com> <51730619.3030204@fastmail.fm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: Will Huck <will.huckk@gmail.com>, Hugh Dickins <hughd@google.com>, Theodore Ts'o <tytso@mit.edu>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

Bernd,

I fact marking REQ_META will help with io scheduler().
I and Andrew will discuss it's some time ago, but don't expect a too =
much performance improvements
anyway - i will pickup patch from Intel jira and ask performance =
engineer to evaluate it.=20

bw. My problem is in memory caching.=20
I may rewrite a buddy cache to avoid using a page cache at all as these =
pages but LRU aging will lost.

On Apr 21, 2013, at 00:18, Bernd Schubert wrote:

> Alex, Andrew,
>=20
> did you notice the patch Ted just sent?
> ("ext4: mark all metadata I/O with REQ_META")
>=20
> I would like to see a way to mark pages read in with REQ_META to be =
kept
> in cache preferred over other pages. I guess that would solve LU-15
> (https://jira.hpdd.intel.com/browse/LU-15) and also the direntry-block
> issue I tried to solve about 2 years ago
> (http://patchwork.ozlabs.org/patch/101200/). But using REQ_META to tag
> pages would probably also solve the same issue for other file systems.
> Is there anything already in the mm layer that could be used for that?
>=20
> Thanks,
> Bernd
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
