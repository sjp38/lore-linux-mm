Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 213886B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 12:44:17 -0400 (EDT)
Message-ID: <20100730164414.88965.qmail@web4208.mail.ogk.yahoo.co.jp>
Date: Sat, 31 Jul 2010 01:44:09 +0900 (JST)
From: Round Robinjp <roundrobinjp@yahoo.co.jp>
Subject: Re: compaction: why depends on HUGETLB_PAGE
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie
Cc: linux-mm@kvack.org, iram.shahzad@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> > Please could you elaborate a little more why depending on=0A> > compact=
ion to satisfy other high-order allocation is not good.=0A> >=0A> =0A> At t=
he very least, it's not a situation that has been tested heavily and=0A> be=
cause other high-order allocations are typically not movable. In the=0A> wo=
rst case, if they are both frequent and long-lived they *may* eventually=0A=
> encounter fragmentation-related problems. This uncertainity is why it's=
=0A> not good. It gets worse if there is no swap as eventually all movable =
pages=0A> will be compacted as much as possible but there still might not b=
e enough=0A> contiguous memory for a high-order page because other pages ar=
e pinned.=0A=0AI am interested in this topic too.=0A=0AHow about using comp=
action for infrequent short-lived=0Ahigh-order allocations? Is there any pr=
oblem in that case?=0A(apart from the point that it is not tested for that =
purpose)=0A=0AAlso how about using compaction as a preparation=0Afor partia=
l refresh?=0A=0ARR=0A=0A--------------------------------------=0AGet the ne=
w Internet Explorer 8 optimized for Yahoo! JAPAN=0Ahttp://pr.mail.yahoo.co.=
jp/ie8/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
