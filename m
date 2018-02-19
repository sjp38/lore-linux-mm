Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0286B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 06:41:14 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id c76so9328675qke.19
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 03:41:14 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y30si3966342qtd.117.2018.02.19.03.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 03:41:13 -0800 (PST)
From: Robert Harris <robert.m.harris@oracle.com>
Message-Id: <8C0380A8-56B9-43C4-9F80-996805FAE980@oracle.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_0D433A24-8820-47A1-80DF-3C3AD7B2662F"
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 0/1] mm, compaction: correct the bounds of
 __fragmentation_index()
Date: Mon, 19 Feb 2018 11:40:39 +0000
In-Reply-To: <20180219082428.GC21134@dhcp22.suse.cz>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <20180219082428.GC21134@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>


--Apple-Mail=_0D433A24-8820-47A1-80DF-3C3AD7B2662F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> On 19 Feb 2018, at 08:24, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Sun 18-02-18 16:47:54, robert.m.harris@oracle.com =
<mailto:robert.m.harris@oracle.com> wrote:
>> From: "Robert M. Harris" <robert.m.harris@oracle.com>
>>=20
>> __fragmentation_index() calculates a value used to determine whether
>> compaction should be favoured over page reclaim in the event of
>> allocation failure.  The function purports to return a value between =
0
>> and 1000, representing units of 1/1000.  Barring the case of a
>> pathological shortfall of memory, the lower bound is instead 500.  =
This
>> is significant because it is the default value of
>> sysctl_extfrag_threshold, i.e. the value below which compaction =
should
>> be avoided in favour of page reclaim for costly pages.
>>=20
>> Here's an illustration using a zone that I fragmented with selective
>> calls to __alloc_pages() and __free_pages --- the fragmentation for
>> order-1 could not be minimised further yet is reported as 0.5:
>=20
> Cover letter for a single patch is usually an overkill. Why is this
> information not valuable in the patch description directly?

This is my first patch and I=E2=80=99m not familiar with all the =
conventions.
I=E2=80=99ll incorporate those details in the next version of the commit =
message.

Robert Harris=

--Apple-Mail=_0D433A24-8820-47A1-80DF-3C3AD7B2662F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><br =
class=3D""><div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On 19 Feb 2018, at 08:24, Michal Hocko &lt;<a =
href=3D"mailto:mhocko@kernel.org" class=3D"">mhocko@kernel.org</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">On Sun 18-02-18 16:47:54,<span =
class=3D"Apple-converted-space">&nbsp;</span></span><a =
href=3D"mailto:robert.m.harris@oracle.com" style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" =
class=3D"">robert.m.harris@oracle.com</a><span style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D""><span =
class=3D"Apple-converted-space">&nbsp;</span>wrote:</span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><blockquote type=3D"cite" style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" class=3D"">From: "Robert M. Harris" =
&lt;<a href=3D"mailto:robert.m.harris@oracle.com" =
class=3D"">robert.m.harris@oracle.com</a>&gt;<br class=3D""><br =
class=3D"">__fragmentation_index() calculates a value used to determine =
whether<br class=3D"">compaction should be favoured over page reclaim in =
the event of<br class=3D"">allocation failure. &nbsp;The function =
purports to return a value between 0<br class=3D"">and 1000, =
representing units of 1/1000. &nbsp;Barring the case of a<br =
class=3D"">pathological shortfall of memory, the lower bound is instead =
500. &nbsp;This<br class=3D"">is significant because it is the default =
value of<br class=3D"">sysctl_extfrag_threshold, i.e. the value below =
which compaction should<br class=3D"">be avoided in favour of page =
reclaim for costly pages.<br class=3D""><br class=3D"">Here's an =
illustration using a zone that I fragmented with selective<br =
class=3D"">calls to __alloc_pages() and __free_pages --- the =
fragmentation for<br class=3D"">order-1 could not be minimised further =
yet is reported as 0.5:<br class=3D""></blockquote><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Cover letter for a single patch is usually an =
overkill. Why is this</span><br style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">information not valuable in the =
patch description directly?</span><br style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""></div></blockquote></div><br class=3D""><div class=3D"">This =
is my first patch and I=E2=80=99m not familiar with all the =
conventions.</div><div class=3D"">I=E2=80=99ll incorporate those details =
in the next version of the commit message.</div><div class=3D""><br =
class=3D""></div><div class=3D"">Robert Harris</div></body></html>=

--Apple-Mail=_0D433A24-8820-47A1-80DF-3C3AD7B2662F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
