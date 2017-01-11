Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9DD36B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 05:55:21 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id o12so49881187lfg.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 02:55:21 -0800 (PST)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id g83si3265027ljg.70.2017.01.11.02.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 02:55:20 -0800 (PST)
Received: by mail-lf0-x234.google.com with SMTP id k86so134303175lfi.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 02:55:20 -0800 (PST)
From: Chris Vest <chris.vest@neotechnology.com>
Message-Id: <E5F4661B-16D8-4A00-BF6C-D8DD2AF8D8A5@neotechnology.com>
Content-Type: multipart/alternative;
 boundary="Apple-Mail=_9F176A49-27D3-41FD-80A2-359837F436F6"
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Date: Wed, 11 Jan 2017 11:55:18 +0100
In-Reply-To: <20170111050356.ldlx73n66zjdkh6i@thunk.org>
References: <20170110160224.GC6179@noname.redhat.com>
 <20170111050356.ldlx73n66zjdkh6i@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Kevin Wolf <kwolf@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>


--Apple-Mail=_9F176A49-27D3-41FD-80A2-359837F436F6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On 11 Jan 2017, at 06.03, Theodore Ts'o <tytso@mit.edu> wrote:
>=20
> So an approach that might work is fsync() will keep the pages dirty
> --- but only while the file descriptor is open.  This could either be
> the default behavior, or something that has to be specifically
> requested via fcntl(2).  That way, as soon as the process exits (at
> which point it will be too late for it do anything to save the
> contents of the file) we also release the memory.  And if the process
> gets OOM killed, again, the right thing happens.  But if the process
> wants to take emergency measures to write the file somewhere else, it
> knows that the pages won't get lost until the file gets closed.


I think this sounds like a very reasonable default. Before reading this =
thread, it would have been my first guess as to how this worked. It =
gives the program the opportunity to retry the fsyncs, before aborting. =
It will also allow a database, for instance, to keep servicing reads =
until the issue resolves itself, or an administrator intervenes. A =
program cannot allow reads from the file if pages that has been written =
to can be evicted, and their changes lost, and then brought back with =
old data.

--
Chris Vest

--Apple-Mail=_9F176A49-27D3-41FD-80A2-359837F436F6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><br class=3D""><div><blockquote type=3D"cite" class=3D""><div =
class=3D"">On 11 Jan 2017, at 06.03, Theodore Ts'o &lt;<a =
href=3D"mailto:tytso@mit.edu" class=3D"">tytso@mit.edu</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"font-family: Menlo-Regular; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">So an approach that might work is fsync() will =
keep the pages dirty</span><br style=3D"font-family: Menlo-Regular; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Menlo-Regular; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; orphans: auto; text-align: start; text-indent: =
0px; text-transform: none; white-space: normal; widows: auto; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">--- but only while the file descriptor is =
open. &nbsp;This could either be</span><br style=3D"font-family: =
Menlo-Regular; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D""><span style=3D"font-family: Menlo-Regular; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; orphans: auto; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; widows: =
auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">the default behavior, or =
something that has to be specifically</span><br style=3D"font-family: =
Menlo-Regular; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D""><span style=3D"font-family: Menlo-Regular; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; orphans: auto; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; widows: =
auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">requested via fcntl(2). =
&nbsp;That way, as soon as the process exits (at</span><br =
style=3D"font-family: Menlo-Regular; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Menlo-Regular; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">which point it will be too late for it do =
anything to save the</span><br style=3D"font-family: Menlo-Regular; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Menlo-Regular; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; orphans: auto; text-align: start; text-indent: =
0px; text-transform: none; white-space: normal; widows: auto; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">contents of the file) we also release the =
memory. &nbsp;And if the process</span><br style=3D"font-family: =
Menlo-Regular; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D""><span style=3D"font-family: Menlo-Regular; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; orphans: auto; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; widows: =
auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">gets OOM killed, again, the =
right thing happens. &nbsp;But if the process</span><br =
style=3D"font-family: Menlo-Regular; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Menlo-Regular; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">wants to take emergency measures to write the =
file somewhere else, it</span><br style=3D"font-family: Menlo-Regular; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Menlo-Regular; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; orphans: auto; text-align: start; text-indent: =
0px; text-transform: none; white-space: normal; widows: auto; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">knows that the pages won't get lost until =
the file gets closed.</span></div></blockquote></div><div class=3D""><br =
class=3D""></div>I think this sounds like a very reasonable default. =
Before reading this thread, it would have been my first guess as to how =
this worked. It gives the program the opportunity to retry the fsyncs, =
before aborting. It will also allow a database, for instance, to keep =
servicing reads until the issue resolves itself, or an administrator =
intervenes. A program cannot allow reads from the file if pages that has =
been written to can be evicted, and their changes lost, and then brought =
back with old data.<br class=3D""><div class=3D""><br class=3D"">--<br =
class=3D"">Chris Vest<br class=3D""></div></body></html>=

--Apple-Mail=_9F176A49-27D3-41FD-80A2-359837F436F6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
