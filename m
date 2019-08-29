Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEC3DC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 14:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 957092189D
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 14:03:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=infodatahub.biz header.i=@infodatahub.biz header.b="Z9e6dELe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 957092189D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infodatahub.biz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E5546B0006; Thu, 29 Aug 2019 10:03:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2961A6B000C; Thu, 29 Aug 2019 10:03:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 185156B000D; Thu, 29 Aug 2019 10:03:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id E53ED6B0006
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 10:03:27 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 646A525717
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 14:03:27 +0000 (UTC)
X-FDA: 75875632854.19.sleep48_3b0bdfed1ee5f
X-HE-Tag: sleep48_3b0bdfed1ee5f
X-Filterd-Recvd-Size: 9721
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 14:03:25 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id 196so2112566pfz.8
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:03:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=infodatahub.biz; s=google;
        h=from:to:references:in-reply-to:subject:date:message-id:mime-version
         :thread-index:content-language:disposition-notification-to;
        bh=hxZnPE5bvITY8/BrL149bp4vKKr5h70K8wTAmjOiyv8=;
        b=Z9e6dELeXphSs/PR9AYJbQ3m9b+4xmogdIyN3gd9zJA7ica6c1w3nw741ZffUH0QWw
         fL/HLc14Muyl6h5wcf14zGk4M4Whza9pFss8OZG/e+KnDI+WNgz8XuqLngAAxE5LikY6
         gqDZ1y3mG9ob+K0gYlksQDziPVtEM+fOTMVa4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:references:in-reply-to:subject:date
         :message-id:mime-version:thread-index:content-language
         :disposition-notification-to;
        bh=hxZnPE5bvITY8/BrL149bp4vKKr5h70K8wTAmjOiyv8=;
        b=BQ9ftHBqWkNmSO91jzreIUnJMhS1B0oO0pXPUfZYQ6fOfjP5iK/c3m+JZgldYIJ1pQ
         4wb/L4H5byWZuTyPkiEcz9+WrtGk0jQD3DhaMiI0n2E59N+CDE76xF67Mcf4+gUMqlYJ
         Rld3qPpI2s5yRuyHI5U/9Y65x0kRJYUMz2zpGcl2iCMfPL6MwskBb6VUUfxiyptkZiOu
         6+CNlpm53oaLn4lIEzexjJ6Mw9BL4s2xu/Lwe5wEKPY5a25S2QMX6VQzXBUCGCtuqjAL
         oh2AvjebzZrqDTMhzPxQH0Qi7llUkRwC1Y8f59cYXFJnKZ4yE6SBPnDFIWeu3JVw2pg1
         rUDQ==
X-Gm-Message-State: APjAAAW+jV28pW/r3dWMgddlPPNYPcIrydu5L0rV3KSiEiNcwfiukqkS
	YPgxVrcSAsYQMzSBw7nESDWMYpPf3cQOvQ==
X-Google-Smtp-Source: APXvYqz9oZobET/iUTNCKPuvzkmg9nmOHQcj9fsJEXV81/UimM79jDhaZd7l5ou74gBabEL8h/sJVA==
X-Received: by 2002:a63:607:: with SMTP id 7mr8444892pgg.240.1567087403933;
        Thu, 29 Aug 2019 07:03:23 -0700 (PDT)
Received: from STRATNEXT97 ([2001:fd0:3300:703::bc32])
        by smtp.gmail.com with ESMTPSA id s7sm6025481pfb.138.2019.08.29.07.03.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 29 Aug 2019 07:03:23 -0700 (PDT)
From: "Chelsey Bobby" <chelsey.bobby@infodatahub.biz>
To: <linux-mm@kvack.org>
References: 
In-Reply-To: 
Subject: RE: CPL
Date: Thu, 29 Aug 2019 10:01:15 -0400
Message-ID: <!&!AAAAAAAAAAAYAAAAAAAAANXmAQ9aI5ZIv7WSR9pTpgTCgAAAEAAAAHSK5e6ilvpLvg2I3FDOStQBAAAAAA==@infodatahub.biz>
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0DE7_01D55E51.0FF2CCF0"
X-Mailer: Microsoft Outlook 15.0
Thread-Index: AdVd2CdfeAj1oM8NRAum/iP1AlvYrwAmYEvA
Content-Language: en-us
X-Bogosity: Ham, tests=bogofilter, spamicity=0.043072, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multipart message in MIME format.

------=_NextPart_000_0DE7_01D55E51.0FF2CCF0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

 

Can you let me know what type of Speciality/Specialists are you looking for?

 

I can send you data with all fields like (Email, phone number, company,
designation etc..)

 

Awaiting your reply.

- Chelsey

 

 

From: Chelsey Bobby [mailto:chelsey.bobby@infodatahub.biz] 
Sent: Wednesday, August 28, 2019 3:39 PM
To: 'linux-mm@kvack.org'
Subject: CPL

 

Hi,

 

Bring excellence to your campaigns with Codependency Professional's List
which includes their contact and email addresses.  

 

If interested let me know the type of contact information that you are
looking for.

 

If you are looking for any other type of Specialty/Specialists just let me
know.

 

Waiting for your response.

 

Thanks and Regards,

Chelsey Bobby.

Sr. Marketing Manager 

 

Note: Before saying no to our product please check the quality and quantity
of our product.

 


------=_NextPart_000_0DE7_01D55E51.0FF2CCF0
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:x=3D"urn:schemas-microsoft-com:office:excel" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns=3D"http://www.w3.org/TR/REC-html40"><head><META =
HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii"><meta name=3DGenerator content=3D"Microsoft Word 15 =
(filtered medium)"><style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:windowtext;
	position:relative;
	top:0pt;
	mso-text-raise:0pt;
	letter-spacing:0pt;
	text-decoration:none none;}
span.EmailStyle18
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]--></head><body lang=3DEN-US =
link=3D"#0563C1" vlink=3D"#954F72"><div class=3DWordSection1><p =
class=3DMsoNormal><span =
style=3D'color:#1F497D'>Hi,<o:p></o:p></span></p><p =
class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p><p =
class=3DMsoNormal><span style=3D'color:#1F497D'>Can you let me know what =
type of <b>Speciality/Specialists</b> are you looking =
for?<o:p></o:p></span></p><p class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p><p =
class=3DMsoNormal><span style=3D'color:#1F497D'>I can send you data with =
all fields like (Email, phone number, company, designation =
etc..)<o:p></o:p></span></p><p class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p><p =
class=3DMsoNormal><span style=3D'color:#1F497D'>Awaiting your =
reply.<o:p></o:p></span></p><p class=3DMsoNormal><span =
style=3D'color:#1F497D'>-</span> <b><span =
style=3D'color:#1F497D'>Chelsey</span></b><span =
style=3D'color:#1F497D'><o:p></o:p></span></p><p class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p><p =
class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p><div><div =
style=3D'border:none;border-top:solid #E1E1E1 1.0pt;padding:3.0pt 0in =
0in 0in'><p class=3DMsoNormal><b>From:</b> Chelsey Bobby =
[mailto:chelsey.bobby@infodatahub.biz] <br><b>Sent:</b> Wednesday, =
August 28, 2019 3:39 PM<br><b>To:</b> =
'linux-mm@kvack.org'<br><b>Subject:</b> CPL<o:p></o:p></p></div></div><p =
class=3DMsoNormal><o:p>&nbsp;</o:p></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span =
style=3D'color:#1F3864'>Hi,<o:p></o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span =
style=3D'color:#1F3864'><o:p>&nbsp;</o:p></span></p><p =
class=3DMsoNormal><span style=3D'color:#1F3864'>Bring excellence to your =
campaigns with <b>Codependency Professional&#8217;s</b> <b>List</b> =
which includes their contact and email addresses.&nbsp; =
<o:p></o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span =
style=3D'color:#1F3864'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span style=3D'color:#1F3864'>If =
interested let me know the type of contact information that you are =
looking for.<o:p></o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span =
style=3D'color:#1F3864'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span style=3D'color:#1F3864'>If you are =
looking for any other type of <b>Specialty/Specialists</b> just let me =
know.<o:p></o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span =
style=3D'color:#1F3864'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span style=3D'color:#1F3864'>Waiting for =
your response.<o:p></o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span =
style=3D'color:#1F3864'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span style=3D'color:#1F3864'>Thanks and =
Regards,<o:p></o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><b><span style=3D'color:#1F3864'>Chelsey =
Bobby.<o:p></o:p></span></b></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span style=3D'color:#1F3864'>Sr. =
Marketing Manager <o:p></o:p></span></p><p class=3DMsoNormal =
style=3D'text-autospace:none'><span =
style=3D'color:#1F3864'><o:p>&nbsp;</o:p></span></p><p =
class=3DMsoNormal><span style=3D'font-size:10.0pt;color:#1F4E79'>Note: =
Before saying no to our product please check the quality and quantity of =
our product.<o:p></o:p></span></p><p =
class=3DMsoNormal><o:p>&nbsp;</o:p></p></div></body></html>
------=_NextPart_000_0DE7_01D55E51.0FF2CCF0--


