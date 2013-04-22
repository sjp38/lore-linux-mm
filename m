Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 27A546B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 08:15:05 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id l13so4520605wie.1
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 05:15:03 -0700 (PDT)
Subject: Re: page eviction from the buddy cache
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <20130420235718.GA28789@thunk.org>
Date: Mon, 22 Apr 2013 15:14:55 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <128E4C4E-555C-43B6-9BA4-7914CBAF5B62@gmail.com>
References: <51504A40.6020604@ya.ru> <20130327150743.GC14900@thunk.org> <alpine.LNX.2.00.1303271135420.29687@eggly.anvils> <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com> <515CD665.9000300@gmail.com> <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com> <51730619.3030204@fastmail.fm> <20130420235718.GA28789@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Bernd Schubert <bernd.schubert@fastmail.fm>, Will Huck <will.huckk@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de

Theodore,

May you provide more details about discussion and new interface?
someone from mm think we need to implement mark_acccessed_force() with =
avoiding is in LRU checks?
and move single page directly without waiting a LRU drain ?


On Apr 21, 2013, at 02:57, Theodore Ts'o wrote:

> On Sat, Apr 20, 2013 at 11:18:17PM +0200, Bernd Schubert wrote:
>> Alex, Andrew,
>>=20
>> did you notice the patch Ted just sent?
>> ("ext4: mark all metadata I/O with REQ_META")
>=20
> This patch was sent to fix another issue that was brought up at Linux
> Storage, Filesystem, and MM workshop.  I did bring up this issue with
> Mel Gorman while at LSF/MM, and as a result, tThe mm folks are going
> to look into making mark_page_accessed() do the right thing, or
> perhaps provide us with new interface.  The problem with forcing the
> page to be marked as activated is this would cause a TLB flush, which
> would be pointless since this these buddy bitmap pages aren't actually
> mapped in anywhere.
>=20
> 						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
