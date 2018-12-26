Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,MIME_HTML_ONLY,
	SPF_PASS,T_KAM_HTML_FONT_INVALID autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2743C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 12:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4B4521720
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 12:10:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=e.atlantisthepalm.com header.i=noreply@e.atlantisthepalm.com header.b="kTwT6kuc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4B4521720
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=e.atlantisthepalm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80B088E0002; Wed, 26 Dec 2018 07:10:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 792408E0003; Wed, 26 Dec 2018 07:10:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60BD78E0002; Wed, 26 Dec 2018 07:10:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D88908E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 07:10:17 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w4so6521764wrt.21
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 04:10:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:errors-to:message-id
         :list-unsubscribe:mime-version:from:to:date:subject
         :content-transfer-encoding;
        bh=Qt3yBUH93X3EJCigXvYcqdBTV+vTMr+oHznVxprUsUc=;
        b=Eg8wcUlLvkAIuSODby8O5jMSPnqoscwEcfupsC9wlSmVT2t2RnrDprkmgheijB/9sL
         NNZOeMdREmaZHFx8jJniWAKt5i64xutFQ/Usjz+EuDY8NB7DptowXnxQcIHvjbNNQnlR
         +pUEohP5BLHVZxAtF69J09QH1BK7FsF/uhYtjKItwZtDv/F043iHo8/MSgma79H/L8qm
         BMn7fGiUg6LV25yTgsC0u/AmKab6/7AoQ7CxS5H8LacqSEm3PQ74vNRfOBIjeoPd7Psx
         bXNikzMi8/mxvs32qdkIsf8DkxiNXNK2WvA8ChuzA6lav+TAOzKmHck3vXhcYuOyeaE6
         UimQ==
X-Gm-Message-State: AJcUukc5VsH0PzgJFewKFkgCjiJ+Mw+c94ctt8KTKEbVQJvwQVEEg7Gg
	X/Rc8XBG79aPWaJnMZjhAvvZpt9DXYWIKjxVL+4fGaIZjmA5ipbEDxIrv7F0knsbE3JdATzrS7M
	OfxmVcgHLCN5D/F0OVaV24/9+PSg0cia4eUvAZP4HY5DbDJe96URyn/uRON7blUVPBg==
X-Received: by 2002:adf:e247:: with SMTP id n7mr17410816wri.205.1545826217211;
        Wed, 26 Dec 2018 04:10:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN40b+BptHeWrxQZ3ABGudZrUWo98EkPxQbLXnBxrr2KkyBHoSHFo/8WS1J85eTsR7W/bECO
X-Received: by 2002:adf:e247:: with SMTP id n7mr17410769wri.205.1545826216335;
        Wed, 26 Dec 2018 04:10:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545826216; cv=none;
        d=google.com; s=arc-20160816;
        b=XZ949KzW3ov0oKdNUoRtCXBSGbvSD+p16h6f5TFpGdZnM3zgRYoFXA52AERI4tAgGR
         VNc6srnMst1XNTIlA/tGImxTf4NIg65EiloB8LnTT+wBN2enU0gwPMOn2x/ExOc6mEwd
         71sbj5j081DQHCa/AgVLDTg9JeE8Gw1Nac66AtHeQ+bdvMkpm3IVgJ0TCi0LGvf5RVS4
         4B98oAwgeww8aeYYZ5b+SOvZbQ/L6ydsG0uEZElrj0sfixygkaWIg7HAqOYaKzjC+ZM6
         BQCUQXcMu1uF/eO7joizPsXxa6KRMg9EjsuCTszCX0o3TWfNoyA9BCVNmRbXT56m0/sc
         76CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:subject:date:to:from:mime-version
         :list-unsubscribe:message-id:errors-to:dkim-signature;
        bh=Qt3yBUH93X3EJCigXvYcqdBTV+vTMr+oHznVxprUsUc=;
        b=Dklhe9Si3zQnzrg0gvRIjPdkscHpcHySRE984IkvIzMg8/YeRUhYdu68XwK2/yCcNH
         uLfG9dqgwpZFsBIkoBP0KOkerbPi8/4BGHQMtnTUnWsRdObPBiALsRclRSDutj3cRoAU
         Xsg+oyFoXuOhP5KEjGb//tCEO/Ht28AfosE4w1RafSE0Nwqm80508bGY1fj5xtc36Ub0
         q7TiRUYiXhFHMqpzan4wCJMjkcinJmFd3aUk5LmZZGbULNzXDP1VpF9oYAsyRJKjhn9R
         sAfjS8jURGy4LT3ARZOzBFAwcVzZUNEJyHs21e2oibU5p9Rr066gEnE7cQgAmPlERwcM
         1atg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@e.atlantisthepalm.com header.s=0 header.b=kTwT6kuc;
       spf=pass (google.com: domain of noreply@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) smtp.mailfrom=noreply@e.atlantisthepalm.com
Received: from mta109110.e.atlantisthepalm.com (mta109110.e.atlantisthepalm.com. [62.144.109.110])
        by mx.google.com with ESMTPS id 195si16357693wmt.105.2018.12.26.04.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 04:10:16 -0800 (PST)
Received-SPF: pass (google.com: domain of noreply@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) client-ip=62.144.109.110;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@e.atlantisthepalm.com header.s=0 header.b=kTwT6kuc;
       spf=pass (google.com: domain of noreply@e.atlantisthepalm.com designates 62.144.109.110 as permitted sender) smtp.mailfrom=noreply@e.atlantisthepalm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; s=0; d=e.atlantisthepalm.com;
 h=Message-ID:List-Unsubscribe:MIME-Version:From:To:Date:Subject:Content-Type:
 Content-Transfer-Encoding; i=noreply@e.atlantisthepalm.com;
 bh=Qt3yBUH93X3EJCigXvYcqdBTV+vTMr+oHznVxprUsUc=;
 b=kTwT6kuc9eSX6JDSbvKD8hM5wFN4dEi9aK4fw0lmD/z5eESq3eiQn4B0d1rKD8nZ3+vUSgVQMYfK
   O9ifBgmd21zbav6I9C+74t98RAMIAR8YBLy4nWujGXRCUPa89yW7Ny61eTW+ggz/X2th3PAHIUER
   vbUMbRq/5TrKBa+HwSw=
Received: by mta109110.e.atlantisthepalm.com id h4dnqg2bs1k5 for <linux-mm@kvack.org>; Wed, 26 Dec 2018 12:10:15 +0000 (envelope-from <noreply@e.atlantisthepalm.com>)
Message-ID: <404.281336408.201812261210151988783.0047002349@e.atlantisthepalm.com>
List-Unsubscribe: <mailto:unsubscribe-1ffadc4dd0b3e1782745a5f05fb5f36a@e.atlantisthepalm.com?subject=Unsubscribe>
X-Mailer: XyzMailer
X-Xyz-cr: 404
X-Xyz-cn: 12693
X-Xyz-bcn: 12688
X-Xyz-md: 100
X-Xyz-mg: 281336408
X-Xyz-et: 100
X-Xyz-pk: 4004113
X-Xyz-ct: 42140
X-Xyz-bct: 42130
MIME-Version: 1.0
From: "Atlantis, The Palm" <noreply@e.atlantisthepalm.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: 26 Dec 2018 12:10:15 +0000
Subject: Tick off your Bucket List for less!
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.259003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

=0A<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN=
" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html=
 xmlns=3D"http://www.w3.org/1999/xhtml" xmlns:v=3D"urn:schemas-mi=
crosoft-com:vml" xmlns:o=3D"urn:schemas-microsoft-com:office:offi=
ce"><head>=0A    <!--[if gte mso 9]><xml>=0A     <o:OfficeDocumen=
tSettings>=0A      <o:AllowPNG/>=0A      <o:PixelsPerInch>96</o:P=
ixelsPerInch>=0A     </o:OfficeDocumentSettings>=0A    </xml><![e=
ndif]-->=0A    <meta http-equiv=3D"Content-Type" content=3D"text/=
html; charset=3Dutf-8">=0A    <meta name=3D"viewport" content=3D"=
width=3Ddevice-width">=0A    <!--[if !mso]><!--><meta http-equiv=3D=
"X-UA-Compatible" content=3D"IE=3Dedge"><!--<![endif]-->=0A    <t=
itle></title>=0A    =0A    =0A    <style type=3D"text/css" id=3D"=
media-query">=0A      body {=0A  margin: 0;=0A  padding: 0; }=0A=0A=
table, tr, td {=0A  vertical-align: top;=0A  border-collapse: col=
lapse; }=0A=0A.ie-browser table, .mso-container table {=0A  table=
-layout: fixed; }=0A=0A* {=0A  line-height: inherit; }=0A=0Aa[x-a=
pple-data-detectors=3Dtrue] {=0A  color: inherit !important;=0A  =
text-decoration: none !important; }=0A=0A[owa] .img-container div=
, [owa] .img-container button {=0A  display: block !important; }=0A=
=0A[owa] .fullwidth button {=0A  width: 100% !important; }=0A=0A[=
owa] .block-grid .col {=0A  display: table-cell;=0A  float: none =
!important;=0A  vertical-align: top; }=0A=0A.ie-browser .num12, .=
ie-browser .block-grid, [owa] .num12, [owa] .block-grid {=0A  wid=
th: 600px !important; }=0A=0A.ExternalClass, .ExternalClass p, .E=
xternalClass span, .ExternalClass font, .ExternalClass td, .Exter=
nalClass div {=0A  line-height: 100%; }=0A=0A.ie-browser .mixed-t=
wo-up .num4, [owa] .mixed-two-up .num4 {=0A  width: 200px !import=
ant; }=0A=0A.ie-browser .mixed-two-up .num8, [owa] .mixed-two-up =
.num8 {=0A  width: 400px !important; }=0A=0A.ie-browser .block-gr=
id.two-up .col, [owa] .block-grid.two-up .col {=0A  width: 300px =
!important; }=0A=0A.ie-browser .block-grid.three-up .col, [owa] .=
block-grid.three-up .col {=0A  width: 200px !important; }=0A=0A.i=
e-browser .block-grid.four-up .col, [owa] .block-grid.four-up .co=
l {=0A  width: 150px !important; }=0A=0A.ie-browser .block-grid.f=
ive-up .col, [owa] .block-grid.five-up .col {=0A  width: 120px !i=
mportant; }=0A=0A.ie-browser .block-grid.six-up .col, [owa] .bloc=
k-grid.six-up .col {=0A  width: 100px !important; }=0A=0A.ie-brow=
ser .block-grid.seven-up .col, [owa] .block-grid.seven-up .col {=0A=
  width: 85px !important; }=0A=0A.ie-browser .block-grid.eight-up=
 .col, [owa] .block-grid.eight-up .col {=0A  width: 75px !importa=
nt; }=0A=0A.ie-browser .block-grid.nine-up .col, [owa] .block-gri=
d.nine-up .col {=0A  width: 66px !important; }=0A=0A.ie-browser .=
block-grid.ten-up .col, [owa] .block-grid.ten-up .col {=0A  width=
: 60px !important; }=0A=0A.ie-browser .block-grid.eleven-up .col,=
 [owa] .block-grid.eleven-up .col {=0A  width: 54px !important; }=
=0A=0A.ie-browser .block-grid.twelve-up .col, [owa] .block-grid.t=
welve-up .col {=0A  width: 50px !important; }=0A=0A@media only sc=
reen and (min-width: 620px) {=0A  .block-grid {=0A    width: 600p=
x !important; }=0A  .block-grid .col {=0A    vertical-align: top;=
 }=0A    .block-grid .col.num12 {=0A      width: 600px !important=
; }=0A  .block-grid.mixed-two-up .col.num4 {=0A    width: 200px !=
important; }=0A  .block-grid.mixed-two-up .col.num8 {=0A    width=
: 400px !important; }=0A  .block-grid.two-up .col {=0A    width: =
300px !important; }=0A  .block-grid.three-up .col {=0A    width: =
200px !important; }=0A  .block-grid.four-up .col {=0A    width: 1=
50px !important; }=0A  .block-grid.five-up .col {=0A    width: 12=
0px !important; }=0A  .block-grid.six-up .col {=0A    width: 100p=
x !important; }=0A  .block-grid.seven-up .col {=0A    width: 85px=
 !important; }=0A  .block-grid.eight-up .col {=0A    width: 75px =
!important; }=0A  .block-grid.nine-up .col {=0A    width: 66px !i=
mportant; }=0A  .block-grid.ten-up .col {=0A    width: 60px !impo=
rtant; }=0A  .block-grid.eleven-up .col {=0A    width: 54px !impo=
rtant; }=0A  .block-grid.twelve-up .col {=0A    width: 50px !impo=
rtant; } }=0A=0A@media (max-width: 620px) {=0A  .block-grid, .col=
 {=0A    min-width: 320px !important;=0A    max-width: 100% !impo=
rtant;=0A    display: block !important; }=0A  .block-grid {=0A   =
 width: calc(100% - 40px) !important; }=0A  .col {=0A    width: 1=
00% !important; }=0A    .col > div {=0A      margin: 0 auto; }=0A=
  img.fullwidth, img.fullwidthOnMobile {=0A    max-width: 100% !i=
mportant; }=0A  .no-stack .col {=0A    min-width: 0 !important;=0A=
    display: table-cell !important; }=0A  .no-stack.two-up .col {=
=0A    width: 50% !important; }=0A  .no-stack.mixed-two-up .col.n=
um4 {=0A    width: 33% !important; }=0A  .no-stack.mixed-two-up .=
col.num8 {=0A    width: 66% !important; }=0A  .no-stack.three-up =
.col.num4 {=0A    width: 33% !important; }=0A  .no-stack.four-up =
.col.num3 {=0A    width: 25% !important; }=0A  .mobile_hide {=0A =
   min-height: 0px;=0A    max-height: 0px;=0A    max-width: 0px;=0A=
    display: none;=0A    overflow: hidden;=0A    font-size: 0px; =
} }=0A=0A    </style>=0A</head>=0A<body class=3D"clean-body" styl=
e=3D"margin: 0;padding: 0;-webkit-text-size-adjust: 100%;backgrou=
nd-color: #FFFFFF"><img src=3D"http://l.e.atlantisthepalm.com/rts=
/open.aspx?tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn" height=
=3D"1" width=3D"1" style=3D"display:none">=0A  <style type=3D"tex=
t/css" id=3D"media-query-bodytag">=0A    @media (max-width: 520px=
) {=0A      .block-grid {=0A        min-width: 320px!important;=0A=
        max-width: 100%!important;=0A        width: 100%!importan=
t;=0A        display: block!important;=0A      }=0A=0A      .col =
{=0A        min-width: 320px!important;=0A        max-width: 100%=
!important;=0A        width: 100%!important;=0A        display: b=
lock!important;=0A      }=0A=0A        .col > div {=0A          m=
argin: 0 auto;=0A        }=0A=0A      img.fullwidth {=0A        m=
ax-width: 100%!important;=0A      }=0Aimg.fullwidthOnMobile {=0A =
       max-width: 100%!important;=0A      }=0A      .no-stack .co=
l {=0Amin-width: 0!important;=0Adisplay: table-cell!important;=0A=
}=0A.no-stack.two-up .col {=0Awidth: 50%!important;=0A}=0A.no-sta=
ck.mixed-two-up .col.num4 {=0Awidth: 33%!important;=0A}=0A.no-sta=
ck.mixed-two-up .col.num8 {=0Awidth: 66%!important;=0A}=0A.no-sta=
ck.three-up .col.num4 {=0Awidth: 33%!important;=0A}=0A.no-stack.f=
our-up .col.num3 {=0Awidth: 25%!important;=0A}=0A      .mobile_hi=
de {=0A        min-height: 0px!important;=0A        max-height: 0=
px!important;=0A        max-width: 0px!important;=0A        displ=
ay: none!important;=0A        overflow: hidden!important;=0A     =
   font-size: 0px!important;=0A      }=0A    }=0A  </style>=0A  <=
!--[if IE]><div class=3D"ie-browser"><![endif]-->=0A  <!--[if mso=
]><div class=3D"mso-container"><![endif]-->=0A  <table class=3D"n=
l-container" style=3D"border-collapse: collapse;table-layout: fix=
ed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;=
vertical-align: top;min-width: 320px;Margin: 0 auto;background-co=
lor: #FFFFFF;width: 100%" cellpadding=3D"0" cellspacing=3D"0">=0A=
<tbody>=0A<tr style=3D"vertical-align: top">=0A<td style=3D"word-=
break: break-word;border-collapse: collapse !important;vertical-a=
lign: top">=0A    <!--[if (mso)|(IE)]><table width=3D"100%" cellp=
adding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td align=3D"cent=
er" style=3D"background-color: #FFFFFF;"><![endif]-->=0A=0A    <d=
iv style=3D"background-color:#FFFFFF;">=0A      <div style=3D"Mar=
gin: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: brea=
k-word;word-wrap: break-word;word-break: break-word;background-co=
lor: transparent;" class=3D"block-grid ">=0A        <div style=3D=
"border-collapse: collapse;display: table;width: 100%;background-=
color:transparent;">=0A          <!--[if (mso)|(IE)]><table width=
=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><t=
d style=3D"background-color:#FFFFFF;" align=3D"center"><table cel=
lpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width: 600=
px;"><tr class=3D"layout-full-width" style=3D"background-color:tr=
ansparent;"><![endif]-->=0A=0A              <!--[if (mso)|(IE)]><=
td align=3D"center" width=3D"600" style=3D" width:600px; padding-=
right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5p=
x; border-top: 0px solid transparent; border-left: 0px solid tran=
sparent; border-bottom: 0px solid transparent; border-right: 0px =
solid transparent;" valign=3D"top"><![endif]-->=0A            <di=
v class=3D"col num12" style=3D"min-width: 320px;max-width: 600px;=
display: table-cell;vertical-align: top;">=0A              <div s=
tyle=3D"background-color: transparent; width: 100% !important;">=0A=
              <!--[if (!mso)&(!IE)]><!--><div style=3D"border-top=
: 0px solid transparent; border-left: 0px solid transparent; bord=
er-bottom: 0px solid transparent; border-right: 0px solid transpa=
rent; padding-top:5px; padding-bottom:5px; padding-right: 0px; pa=
dding-left: 0px;"><!--<![endif]-->=0A=0A                  =0A    =
                <div class=3D"">=0A<!--[if mso]><table width=3D"1=
00%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td sty=
le=3D"padding-right: 10px; padding-left: 10px; padding-top: 10px;=
 padding-bottom: 10px;"><![endif]-->=0A<div style=3D"line-height:=
120%;font-family:Verdana, Geneva, sans-serif;color:#555555; paddi=
ng-right: 10px; padding-left: 10px; padding-top: 10px; padding-bo=
ttom: 10px;">=0A<div style=3D"font-size:12px;line-height:14px;col=
or:#555555;font-family:Verdana, Geneva, sans-serif;text-align:lef=
t;"><p style=3D"margin: 0;font-size: 14px;line-height: 17px;text-=
align: center"><span style=3D"font-size: 12px; line-height: 14px;=
">Bucket List Sale - View the <span style=3D"color: rgb(51, 51, 5=
1); font-size: 12px; line-height: 14px;"><strong><a style=3D"text=
-decoration: none; color: #333333;" href=3D"http://x.e.atlantisth=
epalm.com/ats/msg.aspx?sg1=3D1ffadc4dd0b3e1782745a5f05fb5f36a" ta=
rget=3D"_blank" rel=3D"noopener">web version</a></strong></span><=
/span></p></div>=0A</div>=0A<!--[if mso]></td></tr></table><![end=
if]-->=0A</div>=0A                  =0A              <!--[if (!ms=
o)&(!IE)]><!--></div><!--<![endif]-->=0A              </div>=0A  =
          </div>=0A          <!--[if (mso)|(IE)]></td></tr></tabl=
e></td></tr></table><![endif]-->=0A        </div>=0A      </div>=0A=
    </div>=0A    <div style=3D"background-color:transparent;">=0A=
      <div style=3D"Margin: 0 auto;min-width: 320px;max-width: 60=
0px;overflow-wrap: break-word;word-wrap: break-word;word-break: b=
reak-word;background-color: transparent;" class=3D"block-grid ">=0A=
        <div style=3D"border-collapse: collapse;display: table;wi=
dth: 100%;background-color:transparent;">=0A          <!--[if (ms=
o)|(IE)]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0=
" border=3D"0"><tr><td style=3D"background-color:transparent;" al=
ign=3D"center"><table cellpadding=3D"0" cellspacing=3D"0" border=3D=
"0" style=3D"width: 600px;"><tr class=3D"layout-full-width" style=
=3D"background-color:transparent;"><![endif]-->=0A=0A            =
  <!--[if (mso)|(IE)]><td align=3D"center" width=3D"600" style=3D=
" width:600px; padding-right: 0px; padding-left: 0px; padding-top=
:15px; padding-bottom:15px; border-top: 0px solid transparent; bo=
rder-left: 0px solid transparent; border-bottom: 0px solid transp=
arent; border-right: 0px solid transparent;" valign=3D"top"><![en=
dif]-->=0A            <div class=3D"col num12" style=3D"min-width=
: 320px;max-width: 600px;display: table-cell;vertical-align: top;=
">=0A              <div style=3D"background-color: transparent; w=
idth: 100% !important;">=0A              <!--[if (!mso)&(!IE)]><!=
--><div style=3D"border-top: 0px solid transparent; border-left: =
0px solid transparent; border-bottom: 0px solid transparent; bord=
er-right: 0px solid transparent; padding-top:15px; padding-bottom=
:15px; padding-right: 0px; padding-left: 0px;"><!--<![endif]-->=0A=
=0A                  =0A                    <div align=3D"center"=
 class=3D"img-container center fixedwidth " style=3D"padding-righ=
t: 0px;  padding-left: 0px;">=0A<!--[if mso]><table width=3D"100%=
" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr style=3D"l=
ine-height:0px;line-height:0px;"><td style=3D"padding-right: 0px;=
 padding-left: 0px;" align=3D"center"><![endif]-->=0A  <img class=
=3D"center fixedwidth" align=3D"center" border=3D"0" src=3D"http:=
//wpm.ccmp.eu/wpm/404/ContentUploads/images/w_logo2x_.gif" alt=3D=
"Atlantis the palm" title=3D"Atlantis the palm" style=3D"outline:=
 none;text-decoration: none;-ms-interpolation-mode: bicubic;clear=
: both;display: block !important;border: 0;height: auto;float: no=
ne;width: 100%;max-width: 150px" width=3D"150">=0A<!--[if mso]></=
td></tr></table><![endif]-->=0A</div>=0A=0A                  =0A =
             <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->=0A=
              </div>=0A            </div>=0A          <!--[if (ms=
o)|(IE)]></td></tr></table></td></tr></table><![endif]-->=0A     =
   </div>=0A      </div>=0A    </div>=0A    <div style=3D"backgro=
und-color:transparent;">=0A      <div style=3D"Margin: 0 auto;min=
-width: 320px;max-width: 600px;overflow-wrap: break-word;word-wra=
p: break-word;word-break: break-word;background-color: transparen=
t;" class=3D"block-grid ">=0A        <div style=3D"border-collaps=
e: collapse;display: table;width: 100%;background-color:transpare=
nt;">=0A          <!--[if (mso)|(IE)]><table width=3D"100%" cellp=
adding=3D"0" cellspacing=3D"0" border=3D"0"><tr><td style=3D"back=
ground-color:transparent;" align=3D"center"><table cellpadding=3D=
"0" cellspacing=3D"0" border=3D"0" style=3D"width: 600px;"><tr cl=
ass=3D"layout-full-width" style=3D"background-color:transparent;"=
><![endif]-->=0A=0A              <!--[if (mso)|(IE)]><td align=3D=
"center" width=3D"600" style=3D" width:600px; padding-right: 0px;=
 padding-left: 0px; padding-top:0px; padding-bottom:0px; border-t=
op: 0px solid transparent; border-left: 0px solid transparent; bo=
rder-bottom: 0px solid transparent; border-right: 0px solid trans=
parent;" valign=3D"top"><![endif]-->=0A            <div class=3D"=
col num12" style=3D"min-width: 320px;max-width: 600px;display: ta=
ble-cell;vertical-align: top;">=0A              <div style=3D"bac=
kground-color: transparent; width: 100% !important;">=0A         =
     <!--[if (!mso)&(!IE)]><!--><div style=3D"border-top: 0px sol=
id transparent; border-left: 0px solid transparent; border-bottom=
: 0px solid transparent; border-right: 0px solid transparent; pad=
ding-top:0px; padding-bottom:0px; padding-right: 0px; padding-lef=
t: 0px;"><!--<![endif]-->=0A=0A                  =0A             =
       <div align=3D"center" class=3D"img-container center  autow=
idth  fullwidth " style=3D"padding-right: 0px;  padding-left: 0px=
;">=0A<!--[if mso]><table width=3D"100%" cellpadding=3D"0" cellsp=
acing=3D"0" border=3D"0"><tr style=3D"line-height:0px;line-height=
:0px;"><td style=3D"padding-right: 0px; padding-left: 0px;" align=
=3D"center"><![endif]-->=0A<a href=3D"http://l.e.atlantisthepalm.=
com/rts/go2.aspx?h=3D115975&tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0=
Bss-v8WSn" target=3D"_blank">=0A  <img class=3D"center  autowidth=
  fullwidth" align=3D"center" border=3D"0" src=3D"http://wpm.ccmp=
.eu/wpm/404/ContentUploads/images/New_Folder/MTG-1_1226.jpg" alt=3D=
"Bucket list Sale" title=3D"Bucket list Sale" style=3D"outline: n=
one;text-decoration: none;-ms-interpolation-mode: bicubic;clear: =
both;display: block !important;border: 0;height: auto;float: none=
;width: 100%;max-width: 600px" width=3D"600">=0A<!--[if mso]></td=
></tr></table><![endif]-->=0A</div>=0A=0A                  =0A   =
               =0A                    <div align=3D"center" class=
=3D"img-container center  autowidth  fullwidth " style=3D"padding=
-right: 0px;  padding-left: 0px;">=0A<!--[if mso]><table width=3D=
"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr style=
=3D"line-height:0px;line-height:0px;"><td style=3D"padding-right:=
 0px; padding-left: 0px;" align=3D"center"><![endif]-->=0A  <a hr=
ef=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D115975&tp=3D=
i-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn" target=3D"_blank">=0A =
   <img class=3D"center  autowidth  fullwidth" align=3D"center" b=
order=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/imag=
es/New_Folder/MTG-2_1226.jpg" alt=3D"Image" title=3D"Image" style=
=3D"outline: none;text-decoration: none;-ms-interpolation-mode: b=
icubic;clear: both;display: block !important;border: none;height:=
 auto;float: none;width: 100%;max-width: 600px" width=3D"600">=0A=
  </a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A=
                  =0A                  =0A                    <di=
v align=3D"center" class=3D"img-container center  autowidth  full=
width " style=3D"padding-right: 0px;  padding-left: 0px;">=0A<!--=
[if mso]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0=
" border=3D"0"><tr style=3D"line-height:0px;line-height:0px;"><td=
 style=3D"padding-right: 0px; padding-left: 0px;" align=3D"center=
"><![endif]-->=0A  <a href=3D"http://l.e.atlantisthepalm.com/rts/=
go2.aspx?h=3D115976&tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WS=
n" target=3D"_blank">=0A    <img class=3D"center  autowidth  full=
width" align=3D"center" border=3D"0" src=3D"http://wpm.ccmp.eu/wp=
m/404/ContentUploads/images/New_Folder/MTG-3.jpg" alt=3D"Aquatrek=
" title=3D"Aquatrek" style=3D"outline: none;text-decoration: none=
;-ms-interpolation-mode: bicubic;clear: both;display: block !impo=
rtant;border: none;height: auto;float: none;width: 100%;max-width=
: 600px" width=3D"600">=0A  </a>=0A<!--[if mso]></td></tr></table=
><![endif]-->=0A</div>=0A=0A                  =0A                =
  =0A                    <div align=3D"center" class=3D"img-conta=
iner center  autowidth  fullwidth " style=3D"padding-right: 0px; =
 padding-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellpa=
dding=3D"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-heig=
ht:0px;line-height:0px;"><td style=3D"padding-right: 0px; padding=
-left: 0px;" align=3D"center"><![endif]-->=0A  <a href=3D"http://=
l.e.atlantisthepalm.com/rts/go2.aspx?h=3D115977&tp=3Di-H43-6W-3Ij=
-J2SS0-1c-GneT-1c-J0Bss-v8WSn" target=3D"_blank">=0A    <img clas=
s=3D"center  autowidth  fullwidth" align=3D"center" border=3D"0" =
src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/New_Folde=
r/MTG-4.jpg" alt=3D"Wavehouse" title=3D"Wavehouse" style=3D"outli=
ne: none;text-decoration: none;-ms-interpolation-mode: bicubic;cl=
ear: both;display: block !important;border: none;height: auto;flo=
at: none;width: 100%;max-width: 600px" width=3D"600">=0A  </a>=0A=
<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A       =
           =0A                 =20=0A                    <div ali=
gn=3D"center" class=3D"img-container center  autowidth  fullwidth=
 " style=3D"padding-right: 0px;  padding-left: 0px;">=0A<!--[if m=
so]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" bor=
der=3D"0"><tr style=3D"line-height:0px;line-height:0px;"><td styl=
e=3D"padding-right: 0px; padding-left: 0px;" align=3D"center"><![=
endif]-->=0A  <a href=3D"http://l.e.atlantisthepalm.com/rts/go2.a=
spx?h=3D115978&tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn" ta=
rget=3D"_blank">=0A    <img class=3D"center  autowidth  fullwidth=
" align=3D"center" border=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404=
/ContentUploads/images/New_Folder/MTG-5.jpg" alt=3D"Aquaventure W=
aterpark" title=3D"Aquaventure Waterpark" style=3D"outline: none;=
text-decoration: none;-ms-interpolation-mode: bicubic;clear: both=
;display: block !important;border: none;height: auto;float: none;=
width: 100%;max-width: 600px" width=3D"600">=0A  </a>=0A<!--[if m=
so]></td></tr></table><![endif]-->=0A</div>=0A=0A                =
  =0A                  =0A                    <div class=3D"">=0A=
<!--[if mso]><table width=3D"100%" cellpadding=3D"0" cellspacing=3D=
"0" border=3D"0"><tr><td style=3D"padding-right: 10px; padding-le=
ft: 10px; padding-top: 20px; padding-bottom: 10px;"><![endif]-->=0A=
<div style=3D"line-height:120%;font-family:Verdana, Geneva, sans-=
serif;color:#0068A5; padding-right: 10px; padding-left: 10px; pad=
ding-top: 20px; padding-bottom: 10px;">=0A<div style=3D"font-size=
:12px;line-height:14px;color:#0068A5;font-family:Verdana, Geneva,=
 sans-serif;text-align:left;"><p style=3D"margin: 0;font-size: 14=
px;line-height: 17px;text-align: center"><span style=3D"font-size=
: 15px; line-height: 18px;"><strong>A World Away From Your Everyd=
ay</strong></span></p></div>=0A</div>=0A<!--[if mso]></td></tr></=
table><![endif]-->=0A</div>=0A                  =0A              =
<!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->=0A             =
 </div>=0A            </div>=0A          <!--[if (mso)|(IE)]></td=
></tr></table></td></tr></table><![endif]-->=0A        </div>=0A =
     </div>=0A    </div>=0A    <div style=3D"background-color:tra=
nsparent;">=0A      <div style=3D"Margin: 0 auto;min-width: 320px=
;max-width: 600px;overflow-wrap: break-word;word-wrap: break-word=
;word-break: break-word;background-color: transparent;" class=3D"=
block-grid ">=0A        <div style=3D"border-collapse: collapse;d=
isplay: table;width: 100%;background-color:transparent;">=0A     =
     <!--[if (mso)|(IE)]><table width=3D"100%" cellpadding=3D"0" =
cellspacing=3D"0" border=3D"0"><tr><td style=3D"background-color:=
transparent;" align=3D"center"><table cellpadding=3D"0" cellspaci=
ng=3D"0" border=3D"0" style=3D"width: 600px;"><tr class=3D"layout=
-full-width" style=3D"background-color:transparent;"><![endif]-->=
=0A=0A              <!--[if (mso)|(IE)]><td align=3D"center" widt=
h=3D"600" style=3D" width:600px; padding-right: 0px; padding-left=
: 0px; padding-top:15px; padding-bottom:5px; border-top: 0px soli=
d transparent; border-left: 0px solid transparent; border-bottom:=
 0px solid transparent; border-right: 0px solid transparent;" val=
ign=3D"top"><![endif]-->=0A            <div class=3D"col num12" s=
tyle=3D"min-width: 320px;max-width: 600px;display: table-cell;ver=
tical-align: top;">=0A              <div style=3D"background-colo=
r: transparent; width: 100% !important;">=0A              <!--[if=
 (!mso)&(!IE)]><!--><div style=3D"border-top: 0px solid transpare=
nt; border-left: 0px solid transparent; border-bottom: 0px solid =
transparent; border-right: 0px solid transparent; padding-top:15p=
x; padding-bottom:5px; padding-right: 0px; padding-left: 0px;"><!=
--<![endif]-->=0A=0A                  =0A                    <div=
 class=3D"">=0A<!--[if mso]><table width=3D"100%" cellpadding=3D"=
0" cellspacing=3D"0" border=3D"0"><tr><td style=3D"padding-right:=
 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10p=
x;"><![endif]-->=0A<div style=3D"line-height:120%;font-family:Ver=
dana, Geneva, sans-serif;color:#555555; padding-right: 10px; padd=
ing-left: 10px; padding-top: 10px; padding-bottom: 10px;">=0A<div=
 style=3D"font-size:12px;line-height:14px;color:#555555;font-fami=
ly:Verdana, Geneva, sans-serif;text-align:left;"><p style=3D"marg=
in: 0;font-size: 12px;line-height: 14px;text-align: center"><span=
 style=3D"font-size: 24px; line-height: 28px; color: rgb(0, 101, =
162);">Tell my friends</span></p></div>=0A</div>=0A<!--[if mso]><=
/td></tr></table><![endif]-->=0A</div>=0A                  =0A   =
               =0A                    <div class=3D"" style=3D"fo=
nt-size: 16px;font-family:Verdana, Geneva, sans-serif; text-align=
: center;"><div class=3D"our-class"> =0A<table align=3D"center" b=
order=3D"0" cellpadding=3D"0" cellspacing=3D"0">=0A<tbody>=0A<tr>=
=0A<td><a href=3D"http://l.e.atlantisthepalm.com/rts/social.aspx?=
tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn&amp;sn=3D02&amp;do=
main=3Dx.e.atlantisthepalm.com" target=3D"_blank"><img alt=3D"fac=
ebook" border=3D"0" height=3D"30" src=3D"http://wpm.ccmp.eu/wpm/4=
04/ContentUploads/images/w_facebook2x_.gif" width=3D"30"></a></td=
>=0A<td><img border=3D"0" height=3D"20" src=3D"http://wpm.ccmp.eu=
/wpm/404/ContentUploads/images/t.gif" style=3D"display:block;" wi=
dth=3D"10"></td>=0A<td><a href=3D"http://l.e.atlantisthepalm.com/=
rts/social.aspx?tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn&am=
p;sn=3D18&amp;domain=3Dx.e.atlantisthepalm.com" target=3D"_blank"=
><img alt=3D"linkedin" border=3D"0" height=3D"30" src=3D"http://w=
pm.ccmp.eu/wpm/404/ContentUploads/images/w_linkedin2x_.gif" width=
=3D"30"></a></td>=0A<td><img border=3D"0" height=3D"20" src=3D"ht=
tp://wpm.ccmp.eu/wpm/404/ContentUploads/images/t.gif" style=3D"di=
splay:block;" width=3D"10"></td>=0A<td><a href=3D"http://l.e.atla=
ntisthepalm.com/rts/social.aspx?tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1=
c-J0Bss-v8WSn&amp;sn=3D03&amp;domain=3Dx.e.atlantisthepalm.com" t=
arget=3D"_blank"><img alt=3D"twitter" border=3D"0" height=3D"30" =
src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/w_twitter=
2x_.gif" width=3D"30"></a></td>=0A<td><img border=3D"0" height=3D=
"20" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/t.gi=
f" style=3D"display:block;" width=3D"10"></td>=0A<td><a href=3D"m=
ailto:?subject=3DAtlantis%20Spring%20Sale%20is%20now%20on!&amp;bo=
dy=3D=0A                                                        U=
p%20to%2030%25%20off%20rooms!%20Book%20now%20at%20atlantisthepalm=
.com/sale%0A%0Ahttp%3A%2F%2Fx.e.atlantisthepalm.com%2Fats%2Fsocia=
l.aspx%3Ftp%3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn" target=3D=
"_blank"><img alt=3D"sms" border=3D"0" src=3D"http://wpm.ccmp.eu/=
wpm/404/ContentUploads/images/w_mailto2x_.gif" width=3D"30"></a><=
/td>=0A</tr>=0A</tbody>=0A</table>=0A</div></div>=0A=0A          =
        =0A              <!--[if (!mso)&(!IE)]><!--></div><!--<![=
endif]-->=0A              </div>=0A            </div>=0A         =
 <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif=
]-->=0A        </div>=0A      </div>=0A    </div>=0A    <div styl=
e=3D"background-color:transparent;">=0A      <div style=3D"Margin=
: 0 auto;min-width: 320px;max-width: 600px;overflow-wrap: break-w=
ord;word-wrap: break-word;word-break: break-word;background-color=
: transparent;" class=3D"block-grid three-up ">=0A        <div st=
yle=3D"border-collapse: collapse;display: table;width: 100%;backg=
round-color:transparent;">=0A          <!--[if (mso)|(IE)]><table=
 width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0">=
<tr><td style=3D"background-color:transparent;" align=3D"center">=
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"=
width: 600px;"><tr class=3D"layout-full-width" style=3D"backgroun=
d-color:transparent;"><![endif]-->=0A=0A              <!--[if (ms=
o)|(IE)]><td align=3D"center" width=3D"200" style=3D" width:200px=
; padding-right: 0px; padding-left: 0px; padding-top:10px; paddin=
g-bottom:5px; border-top: 0px solid transparent; border-left: 0px=
 solid transparent; border-bottom: 0px solid transparent; border-=
right: 0px solid transparent;" valign=3D"top"><![endif]-->=0A    =
        <div class=3D"col num4" style=3D"max-width: 320px;min-wid=
th: 200px;display: table-cell;vertical-align: top;">=0A          =
    <div style=3D"background-color: transparent; width: 100% !imp=
ortant;">=0A              <!--[if (!mso)&(!IE)]><!--><div style=3D=
"border-top: 0px solid transparent; border-left: 0px solid transp=
arent; border-bottom: 0px solid transparent; border-right: 0px so=
lid transparent; padding-top:10px; padding-bottom:5px; padding-ri=
ght: 0px; padding-left: 0px;"><!--<![endif]-->=0A=0A             =
     =0A                    <div align=3D"center" class=3D"img-co=
ntainer center fixedwidth " style=3D"padding-right: 0px;  padding=
-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellpadding=3D=
"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-height:0px;l=
ine-height:0px;"><td style=3D"padding-right: 0px; padding-left: 0=
px;" align=3D"center"><![endif]-->=0A  <a href=3D"http://l.e.atla=
ntisthepalm.com/rts/go2.aspx?h=3D115979&tp=3Di-H43-6W-3Ij-J2SS0-1=
c-GneT-1c-J0Bss-v8WSn" target=3D"_blank">=0A    <img class=3D"cen=
ter fixedwidth" align=3D"center" border=3D"0" src=3D"http://wpm.c=
cmp.eu/wpm/404/ContentUploads/images/w_livecam2x_new.gif" alt=3D"=
Atlantis Live Cam" title=3D"Atlantis Live Cam" style=3D"outline: =
none;text-decoration: none;-ms-interpolation-mode: bicubic;clear:=
 both;display: block !important;border: none;height: auto;float: =
none;width: 100%;max-width: 170px" width=3D"170">=0A  </a>=0A<!--=
[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A           =
       =0A              <!--[if (!mso)&(!IE)]><!--></div><!--<![e=
ndif]-->=0A              </div>=0A            </div>=0A          =
    <!--[if (mso)|(IE)]></td><td align=3D"center" width=3D"200" s=
tyle=3D" width:200px; padding-right: 0px; padding-left: 0px; padd=
ing-top:10px; padding-bottom:5px; border-top: 0px solid transpare=
nt; border-left: 0px solid transparent; border-bottom: 0px solid =
transparent; border-right: 0px solid transparent;" valign=3D"top"=
><![endif]-->=0A            <div class=3D"col num4" style=3D"max-=
width: 320px;min-width: 200px;display: table-cell;vertical-align:=
 top;">=0A              <div style=3D"background-color: transpare=
nt; width: 100% !important;">=0A              <!--[if (!mso)&(!IE=
)]><!--><div style=3D"border-top: 0px solid transparent; border-l=
eft: 0px solid transparent; border-bottom: 0px solid transparent;=
 border-right: 0px solid transparent; padding-top:10px; padding-b=
ottom:5px; padding-right: 0px; padding-left: 0px;"><!--<![endif]-=
->=0A=0A                  =0A                    <div align=3D"ce=
nter" class=3D"img-container center fixedwidth " style=3D"padding=
-right: 0px;  padding-left: 0px;">=0A<!--[if mso]><table width=3D=
"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><tr style=
=3D"line-height:0px;line-height:0px;"><td style=3D"padding-right:=
 0px; padding-left: 0px;" align=3D"center"><![endif]-->=0A  <a hr=
ef=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D115980&tp=3D=
i-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn" target=3D"_blank">=0A =
   <img class=3D"center fixedwidth" align=3D"center" border=3D"0"=
 src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/w_about2=
x_new.gif" alt=3D"About Atlantis" title=3D"About Atlantis" style=3D=
"outline: none;text-decoration: none;-ms-interpolation-mode: bicu=
bic;clear: both;display: block !important;border: none;height: au=
to;float: none;width: 100%;max-width: 170px" width=3D"170">=0A  <=
/a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=0A=0A =
                 =0A              <!--[if (!mso)&(!IE)]><!--></di=
v><!--<![endif]-->=0A              </div>=0A            </div>=0A=
              <!--[if (mso)|(IE)]></td><td align=3D"center" width=
=3D"200" style=3D" width:200px; padding-right: 0px; padding-left:=
 0px; padding-top:10px; padding-bottom:5px; border-top: 0px solid=
 transparent; border-left: 0px solid transparent; border-bottom: =
0px solid transparent; border-right: 0px solid transparent;" vali=
gn=3D"top"><![endif]-->=0A            <div class=3D"col num4" sty=
le=3D"max-width: 320px;min-width: 200px;display: table-cell;verti=
cal-align: top;">=0A              <div style=3D"background-color:=
 transparent; width: 100% !important;">=0A              <!--[if (=
!mso)&(!IE)]><!--><div style=3D"border-top: 0px solid transparent=
; border-left: 0px solid transparent; border-bottom: 0px solid tr=
ansparent; border-right: 0px solid transparent; padding-top:10px;=
 padding-bottom:5px; padding-right: 0px; padding-left: 0px;"><!--=
<![endif]-->=0A=0A                  =0A                    <div a=
lign=3D"center" class=3D"img-container center fixedwidth " style=3D=
"padding-right: 0px;  padding-left: 0px;">=0A<!--[if mso]><table =
width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D"0"><=
tr style=3D"line-height:0px;line-height:0px;"><td style=3D"paddin=
g-right: 0px; padding-left: 0px;" align=3D"center"><![endif]-->=0A=
  <a href=3D"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D1159=
81&tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn" target=3D"_bla=
nk">=0A    <img class=3D"center fixedwidth" align=3D"center" bord=
er=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/images/=
w_blog2x_new.gif" alt=3D"Atlantis Blog" title=3D"Atlantis Blog" s=
tyle=3D"outline: none;text-decoration: none;-ms-interpolation-mod=
e: bicubic;clear: both;display: block !important;border: none;hei=
ght: auto;float: none;width: 100%;max-width: 170px" width=3D"170"=
>=0A  </a>=0A<!--[if mso]></td></tr></table><![endif]-->=0A</div>=
=0A=0A                  =0A              <!--[if (!mso)&(!IE)]><!=
--></div><!--<![endif]-->=0A              </div>=0A            </=
div>=0A          <!--[if (mso)|(IE)]></td></tr></table></td></tr>=
</table><![endif]-->=0A        </div>=0A      </div>=0A    </div>=
=0A    <div style=3D"background-color:transparent;">=0A      <div=
 style=3D"Margin: 0 auto;min-width: 320px;max-width: 600px;overfl=
ow-wrap: break-word;word-wrap: break-word;word-break: break-word;=
background-color: transparent;" class=3D"block-grid ">=0A        =
<div style=3D"border-collapse: collapse;display: table;width: 100=
%;background-color:transparent;">=0A          <!--[if (mso)|(IE)]=
><table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=
=3D"0"><tr><td style=3D"background-color:transparent;" align=3D"c=
enter"><table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" st=
yle=3D"width: 600px;"><tr class=3D"layout-full-width" style=3D"ba=
ckground-color:transparent;"><![endif]-->=0A=0A              <!--=
[if (mso)|(IE)]><td align=3D"center" width=3D"600" style=3D" widt=
h:600px; padding-right: 0px; padding-left: 0px; padding-top:5px; =
padding-bottom:5px; border-top: 0px solid transparent; border-lef=
t: 0px solid transparent; border-bottom: 0px solid transparent; b=
order-right: 0px solid transparent;" valign=3D"top"><![endif]-->=0A=
            <div class=3D"col num12" style=3D"min-width: 320px;ma=
x-width: 600px;display: table-cell;vertical-align: top;">=0A     =
         <div style=3D"background-color: transparent; width: 100%=
 !important;">=0A              <!--[if (!mso)&(!IE)]><!--><div st=
yle=3D"border-top: 0px solid transparent; border-left: 0px solid =
transparent; border-bottom: 0px solid transparent; border-right: =
0px solid transparent; padding-top:5px; padding-bottom:5px; paddi=
ng-right: 0px; padding-left: 0px;"><!--<![endif]-->=0A=0A        =
          =0A                    <div class=3D"">=0A<!--[if mso]>=
<table width=3D"100%" cellpadding=3D"0" cellspacing=3D"0" border=3D=
"0"><tr><td style=3D"padding-right: 10px; padding-left: 10px; pad=
ding-top: 20px; padding-bottom: 20px;"><![endif]-->=0A<div style=3D=
"line-height:120%;font-family:Verdana, Geneva, sans-serif;color:#=
555555; padding-right: 10px; padding-left: 10px; padding-top: 20p=
x; padding-bottom: 20px;">=0A<div style=3D"font-size:12px;line-he=
ight:14px;color:#555555;font-family:Verdana, Geneva, sans-serif;t=
ext-align:left;"><p style=3D"margin: 0;font-size: 14px;line-heigh=
t: 17px;text-align: center"><span style=3D"font-size: 12px; line-=
height: 14px; color: rgb(136, 136, 136);">Terms &amp; Conditions =
apply. </span><br><br><span style=3D"font-size: 12px; line-height=
: 14px; color: rgb(136, 136, 136);">Copyright 2018, Atlantis, Ker=
zner P.O. Box 211222, UAE, Atlantis The Palm. </span><br><br><spa=
n style=3D"font-size: 12px; line-height: 14px; color: rgb(136, 13=
6, 136);">To unsubscribe from this Atlantis, The Palm list please=
 click <a style=3D"text-decoration: none; color: #888888;" href=3D=
"http://l.e.atlantisthepalm.com/rts/go2.aspx?h=3D115982&tp=3Di-H4=
3-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn&x=3Di-H43-6W-3Ij-J2SS0-1c-G=
neT-1c-J0Bss-v8WSn" target=3D"_blank" rel=3D"noopener"><span styl=
e=3D"color: rgb(51, 51, 51); font-size: 12px; line-height: 14px;"=
><strong>here</strong></span></a>. </span><br><br><span style=3D"=
font-size: 12px; line-height: 14px; color: rgb(136, 136, 136);">R=
eview Atlantis, The Palm <span style=3D"color: rgb(51, 51, 51); f=
ont-size: 12px; line-height: 14px;"><strong><a style=3D"text-deco=
ration: none; color: #333333;" href=3D"http://l.e.atlantisthepalm=
.com/rts/go2.aspx?h=3D115983&tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J=
0Bss-v8WSn" target=3D"_blank" rel=3D"noopener">Privacy Policy</a>=
</strong></span> and <span style=3D"color: rgb(51, 51, 51); font-=
size: 12px; line-height: 14px;"><a style=3D"text-decoration: none=
; color: #333333;" href=3D"http://l.e.atlantisthepalm.com/rts/go2=
.aspx?h=3D115984&tp=3Di-H43-6W-3Ij-J2SS0-1c-GneT-1c-J0Bss-v8WSn" =
target=3D"_blank" rel=3D"noopener"><span style=3D"font-size: 12px=
; line-height: 14px;"><strong>Terms and Conditions</strong></span=
></a></span>. </span><br><br><span style=3D"font-size: 12px; line=
-height: 14px; color: rgb(136, 136, 136);">Please do not reply to=
 this email.</span></p></div>=0A</div>=0A<!--[if mso]></td></tr><=
/table><![endif]-->=0A</div>=0A                  =0A             =
     =0A                    <div align=3D"center" class=3D"img-co=
ntainer center fixedwidth " style=3D"padding-right: 0px;  padding=
-left: 0px;">=0A<!--[if mso]><table width=3D"100%" cellpadding=3D=
"0" cellspacing=3D"0" border=3D"0"><tr style=3D"line-height:0px;l=
ine-height:0px;"><td style=3D"padding-right: 0px; padding-left: 0=
px;" align=3D"center"><![endif]-->=0A  <a href=3D"www.atlantisthe=
palm.com/festive?utm_source=3Dcrm&amp;utm_medium=3Demail&amp;utm_=
campaign=3Dem_F&amp;BFestiveBSK&amp;Seafire_atp_07122018" target=3D=
"_blank">=0A    <img class=3D"center fixedwidth" align=3D"center"=
 border=3D"0" src=3D"http://wpm.ccmp.eu/wpm/404/ContentUploads/im=
ages/w_logo2x_.gif" alt=3D"Atlantis the palm" title=3D"Atlantis t=
he palm" style=3D"outline: none;text-decoration: none;-ms-interpo=
lation-mode: bicubic;clear: both;display: block !important;border=
: none;height: auto;float: none;width: 100%;max-width: 180px" wid=
th=3D"180">=0A  </a>=0A<!--[if mso]></td></tr></table><![endif]--=
>=0A</div>=0A=0A                  =0A              <!--[if (!mso)=
&(!IE)]><!--></div><!--<![endif]-->=0A              </div>=0A    =
        </div>=0A          <!--[if (mso)|(IE)]></td></tr></table>=
</td></tr></table><![endif]-->=0A        </div>=0A      </div>=0A=
    </div>=0A   <!--[if (mso)|(IE)]></td></tr></table><![endif]--=
>=0A</td>=0A  </tr>=0A  </tbody>=0A  </table>=0A  <!--[if (mso)|(=
IE)]></div><![endif]-->=0A=0A=0A</body></html>

