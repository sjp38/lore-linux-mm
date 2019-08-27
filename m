Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F226C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 13:29:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3986820673
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 13:29:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3986820673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B96A16B0008; Tue, 27 Aug 2019 09:29:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B46F86B000A; Tue, 27 Aug 2019 09:29:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A36646B000C; Tue, 27 Aug 2019 09:29:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0114.hostedemail.com [216.40.44.114])
	by kanga.kvack.org (Postfix) with ESMTP id 848986B0008
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 09:29:31 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 17D8162D9
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:29:31 +0000 (UTC)
X-FDA: 75868289742.23.light11_52e11b06f1232
X-HE-Tag: light11_52e11b06f1232
X-Filterd-Recvd-Size: 4966
Received: from mail3-166.sinamail.sina.com.cn (mail3-166.sinamail.sina.com.cn [202.108.3.166])
	by imf27.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:29:29 +0000 (UTC)
Received: from unknown (HELO [IPv6:::ffff:192.168.199.155])([114.254.173.51])
	by sina.com with ESMTP
	id 5D6530330002EA88; Tue, 27 Aug 2019 21:29:26 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 14190454982534
MIME-Version: 1.0
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Adric Blake <promarbler14@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Kirill Tkhai <ktkhai@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Yang Shi <yang.shi@linux.alibaba.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
From: Hillf Danton <hdanton@sina.com>
Subject: Re: WARNINGs in set_task_reclaim_state with memory
 cgroupandfullmemory usage
Date: Tue, 27 Aug 2019 21:29:24 +0800
Importance: normal
X-Priority: 3
In-Reply-To:
 <CALOAHbAuY9BnpX6x4KSNURbzybjn5UdSNL7-1Li3R0HSQBqiGQ@mail.gmail.com>
References: <20190824130516.2540-1-hdanton@sina.com>
 <CALOAHbAuY9BnpX6x4KSNURbzybjn5UdSNL7-1Li3R0HSQBqiGQ@mail.gmail.com>
Content-Type: multipart/alternative;
	boundary="_C8E0572E-CB3B-4C3E-82BC-F8B8094DD781_"
Message-Id: <20190827132931.848986B0008@kanga.kvack.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--_C8E0572E-CB3B-4C3E-82BC-F8B8094DD781_
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"


>> No preference seems in either way except for retaining
>> nr_to_reclaim =3D=3D SWAP_CLUSTER_MAX and target_mem_cgroup =3D=3D memcg=
.
>
> Setting  target_mem_cgroup here may be a very subtle change for
> subsequent processing.
> Regarding retraining nr_to_reclaim =3D=3D SWAP_CLUSTER_MAX, it may not
> proper for direct reclaim, that may cause some stall if we iterate all
> memcgs here.

Mind posting a RFC to collect thoughts?


--_C8E0572E-CB3B-4C3E-82BC-F8B8094DD781_
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset="utf-8"

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40"><head><meta ht=
tp-equiv=3DContent-Type content=3D"text/html; charset=3Dutf-8"><meta name=
=3DGenerator content=3D"Microsoft Word 15 (filtered medium)"><style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:DengXian;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:DengXian;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	font-size:10.5pt;
	font-family:DengXian;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.DefaultFontHxMailStyle
	{mso-style-name:"Default Font HxMail Style";
	font-family:DengXian;
	color:windowtext;
	font-weight:normal;
	font-style:normal;
	text-decoration:none none;}
.MsoChpDefault
	{mso-style-type:export-only;}
/* Page Definitions */
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style></head><body lang=3DZH-CN link=3Dblue vlink=3D"#954F72"><div cla=
ss=3DWordSection1><p class=3DMsoNormal><span lang=3DEN-US><o:p>&nbsp;</o:p>=
</span></p><p class=3DMsoNormal><span lang=3DEN-US>&gt;&gt; No preference s=
eems in either way except for retaining</span></p><p class=3DMsoNormal><spa=
n lang=3DEN-US>&gt;&gt; nr_to_reclaim =3D=3D SWAP_CLUSTER_MAX and target_me=
m_cgroup =3D=3D memcg.</span></p><p class=3DMsoNormal><span lang=3DEN-US>&g=
t;<o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal><span lang=3DEN-US>&gt; =
Setting=C2=A0 target_mem_cgroup here may be a very subtle change for</span>=
</p><p class=3DMsoNormal><span lang=3DEN-US>&gt; subsequent processing.</sp=
an></p><p class=3DMsoNormal><span lang=3DEN-US>&gt; Regarding retraining nr=
_to_reclaim =3D=3D SWAP_CLUSTER_MAX, it may not</span></p><p class=3DMsoNor=
mal><span lang=3DEN-US>&gt; proper for direct reclaim, that may cause some =
stall if we iterate all</span></p><p class=3DMsoNormal><span lang=3DEN-US>&=
gt; memcgs here.</span></p><p class=3DMsoNormal><span lang=3DEN-US><o:p>&nb=
sp;</o:p></span></p><p class=3DMsoNormal><span lang=3DEN-US>Mind posting a =
RFC to collect thoughts?</span></p><p class=3DMsoNormal><span class=3DDefau=
ltFontHxMailStyle><span lang=3DEN-US><o:p>&nbsp;</o:p></span></span></p></d=
iv></body></html>=

--_C8E0572E-CB3B-4C3E-82BC-F8B8094DD781_--



