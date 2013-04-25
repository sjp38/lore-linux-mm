Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id CB8216B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 04:18:26 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id h11so8310112wiv.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 01:18:25 -0700 (PDT)
Subject: Re: page eviction from the buddy cache
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <20130424144130.0d28b94b229b915d7f9c7840@linux-foundation.org>
Date: Thu, 25 Apr 2013 11:18:17 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <8476E09F-D2DF-4685-A22F-0555475BD481@gmail.com>
References: <alpine.LNX.2.00.1303271135420.29687@eggly.anvils> <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com> <515CD665.9000300@gmail.com> <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com> <51730619.3030204@fastmail.fm> <20130420235718.GA28789@thunk.org> <5176785D.5030707@fastmail.fm> <20130423122708.GA31170@thunk.org> <alpine.LNX.2.00.1304231230340.12850@eggly.anvils> <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org> <20130424142650.GA29097@thunk.org> <20130424144130.0d28b94b229b915d7f9c7840@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, Will Huck <will.huckk@gmail.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

So, right direction add ability to mark a page as active in lru pagevec =
array ?
just a bypass a IS_IN_LRU(page) check and fix moving to LRU to ability =
to put into active LRU list from pagevec ?
I may prepare a patch for it.

On Apr 25, 2013, at 00:41, Andrew Morton wrote:

> On Wed, 24 Apr 2013 10:26:50 -0400 "Theodore Ts'o" <tytso@mit.edu> =
wrote:
>=20
>> On Tue, Apr 23, 2013 at 03:00:08PM -0700, Andrew Morton wrote:
>>> That should fix things for now.  Although it might be better to just =
do
>>>=20
>>> 	mark_page_accessed(page);	/* to SetPageReferenced */
>>> 	lru_add_drain();		/* to SetPageLRU */
>>>=20
>>> Because a) this was too early to decide that the page is
>>> super-important and b) the second touch of this page should have a
>>> mark_page_accessed() in it already.
>>=20
>> The question is do we really want to put lru_add_drain() into the =
ext4
>> file system code?  That seems to pushing some fairly mm-specific
>> knowledge into file system code.  I'll do this if I have to do, but
>> wouldn't be better if this was pushed into mark_page_accessed(), or
>> some other new API was exported by the mm subsystem?
>=20
> Sure, that would be daft.  We'd add a new
> mark_page_accessed_right_now_dont_use_this() to mm/swap.c
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
