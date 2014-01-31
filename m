Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 57D806B0036
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 10:39:27 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id e16so7164704qcx.38
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 07:39:27 -0800 (PST)
Received: from omr-d08.mx.aol.com (omr-d08.mx.aol.com. [205.188.109.207])
        by mx.google.com with ESMTPS id v8si7855712qab.161.2014.01.31.07.39.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 07:39:26 -0800 (PST)
Date: Fri, 31 Jan 2014 09:39:25 -0600
From: <boxerapp@aol.com>
Message-ID: <87BDA3C8-659F-4D58-9923-CEF441DDDAEF@aol.com>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on
 memcg_create_kmem_cache fail path
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="52ebc3ad_66334873_7f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--52ebc3ad_66334873_7f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I've added this to my to-do list. On January 30, 2014 at 4:09:02 PM CST, =
Andrew Morton  wrote:On Thu, 30 Jan 2014 14:04:12 -0800 (PST) David Rient=
jes  wrote:> On Thu, 30 Jan 2014, Andrew Morton wrote:> > > > Yeah, it sh=
ouldn't be temporary it should be the one and only allocation. > > > We s=
hould construct the name in memcg=5Fcreate=5Fkmem=5Fcache() and be done w=
ith > > > it.> > > > Could. That would require converting memcg=5Fcreate=5F=
kmem=5Fcache() to take > > a va=5Flist and call kasprintf() on it.> > > >=
 Why=3F We already construct the name in memcg=5Fcreate=5Fkmem=5Fcache() =
> appropriately, we just want to avoid the kstrdup() in > kmem=5Fcache=5F=
create=5Fmemcg() since it's pointless like my patch does.oh, OK, missed t=
hat.The problem now is that the string at kmem=5Fcache.name is PATH=5FMAX=
bytes, and PATH=5FMAX is huuuuuuuge.--To unsubscribe from this list: send=
 the line =22unsubscribe linux-kernel=22 inthe body of a message to major=
domo=40vger.kernel.orgMore majordomo info at http://vger.kernel.org/major=
domo-info.htmlPlease read the =46AQ at http://www.tux.org/lkml/     
--52ebc3ad_66334873_7f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html><body><div>I've added this to my to-do list.</div><br/><br/><div><d=
iv class=3D=22quote=22>On January 30, 2014 at 4:09:02 PM CST, Andrew Mort=
on <akpm=40linux-foundation.org> wrote:<br/><blockquote type=3D=22cite=22=
 style=3D=22border-left-style:solid;border-width:1px;margin-left:0px;padd=
ing-left:10px;=22>On Thu, 30 Jan 2014 14:04:12 -0800 (PST) David Rientjes=
 <rientjes=40google.com> wrote:<br /><br />> On Thu, 30 Jan 2014, Andrew =
Morton wrote:<br />> <br />> > > Yeah, it shouldn't be temporary it shoul=
d be the one and only allocation.  <br />> > > We should construct the na=
me in memcg=5Fcreate=5Fkmem=5Fcache() and be done with <br />> > > it.<br=
 />> > <br />> > Could.  That would require converting memcg=5Fcreate=5Fk=
mem=5Fcache() to take <br />> > a va=5Flist and call kasprintf() on it.<b=
r />> > <br />> <br />> Why=3F  We already construct the name in memcg=5F=
create=5Fkmem=5Fcache() <br />> appropriately, we just want to avoid the =
kstrdup() in <br />> kmem=5Fcache=5Fcreate=5Fmemcg() since it's pointless=
 like my patch does.<br /><br />oh, OK, missed that.<br /><br />The probl=
em now is that the string at kmem=5Fcache.name is PATH=5FMAX<br />bytes, =
and PATH=5FMAX is huuuuuuuge.<br /><br />--<br />To unsubscribe from this=
 list: send the line =22unsubscribe linux-kernel=22 in<br />the body of a=
 message to majordomo=40vger.kernel.org<br />More majordomo info at  http=
://vger.kernel.org/majordomo-info.html<br />Please read the =46AQ at  htt=
p://www.tux.org/lkml/<br /></blockquote></div></div></body></html>
--52ebc3ad_66334873_7f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
