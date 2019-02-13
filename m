Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FROM_EXCESS_BASE64,HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4535DC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:11:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E25E921904
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:11:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=googlegroups.com header.i=@googlegroups.com header.b="BCDm0mNL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E25E921904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=googlegroups.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74BD48E0002; Wed, 13 Feb 2019 02:11:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FA038E0001; Wed, 13 Feb 2019 02:11:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E9808E0002; Wed, 13 Feb 2019 02:11:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 355298E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 02:11:10 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id a19so1293264otq.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 23:11:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:date:auto-submitted
         :message-id:subject:from:to;
        bh=lvcVrEvr7ANzwNdqlrmbwwWw2zDaYkh1BArZAgLt5Po=;
        b=FkoPzjNo+Ljtbq1XDFjxTdMfCzPqoVFyFyOVXtFy5Fg0VfLcfSv7sI0xW8VqKp6dWF
         BjBtEhT+XDTFggLBJgr9YPa+FV0JxbhZ6dPGPfgMpmkvoKQiJ4RnAUTB4U1j2nYZHxXC
         lGhPK/TYyiEW19MQP4urbEuXBa+tnKo+GWVdzCMP1eMO81VkI/ebNwCqqyo+FjC2TRk1
         C+R5Yyxx3SU7479huZL1wtSzSwxViSc9sjR1bLgdvYGn2Cp+zhGbhKyFMGL4d42OOiKY
         r1KlGPUliztkheULyCsfL5UE8b2W3Ygob5Sg+4WvaqGUbalkSKOGCa8N9teResLCq7o/
         1SYw==
X-Gm-Message-State: AHQUAuZ3GcdraW00vdBD/RUBeRaqbZJDSWs551ONJA5g/eFoQFEeJmwm
	vt2/r73pLZFQTgREko8xtLx53cgBYR2fc6yhVYoZtep9LSL29rol2+4FFfUIlrCXLEQQzH+pAOh
	NDfiHoRkjI7ekOTxFRrswzbhDgaOGQKG6pHbMWq45ZOv31RTY7U5NmC4Xq6zvbVF3wZZdc+fJz+
	HuLoB3XAm6xv+KSLFTKFBDzYctbcfzBLN2nfrT6ZYlBR2vzlpRFow+yOeX0mSoYWTXquyVI/Gam
	Ygu2yQ+LP4/Y01wU1yFncPPDh2/xq74JjMJB0tJHL9HivIEFeWM5x43st+hikitDpaqzJ7gXwSX
	rvUoZf1tZzGi1H/XLK6L4kqqdIE7xU/aYUcrZjprF4MJI4/8JBjclm4mGGkheBzRhNwQcKJPjAp
	0
X-Received: by 2002:a9d:7c90:: with SMTP id q16mr99992otn.349.1550041869840;
        Tue, 12 Feb 2019 23:11:09 -0800 (PST)
X-Received: by 2002:a9d:7c90:: with SMTP id q16mr99970otn.349.1550041869132;
        Tue, 12 Feb 2019 23:11:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550041869; cv=none;
        d=google.com; s=arc-20160816;
        b=UeZE1OgwQc29xgndn8gaAeHBBB6HwpaTgUG+BttQBU8d97J/ZFwakMJ8MeMLjm9zoT
         oq/Akv8D8t+3rPfuwlToOgcaFfTQrfQ+pvn3J6ErDCbNYram4S8FNhRKkB2ke7zABsLn
         opLoT/UiGScDNRz4NXpbntijPoYmMyakwA2iyKVgb8JO/MTZVxH+IVq5vWMwsi9hsIqa
         9yf15kozTwjUcTYm8tZ/3M6H97CStLqWXXUyThLcX3Ct+8vx3pTooaScgM6Rn82Ysm3S
         e6LptOwdeWDHJvKFVa1xlWJzsjmMCmtGyhHU9ews0Oe7C0MhsjTGCQKE16RB0CxdonAV
         X5iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:auto-submitted:date:mime-version
         :dkim-signature;
        bh=lvcVrEvr7ANzwNdqlrmbwwWw2zDaYkh1BArZAgLt5Po=;
        b=IDdA2N4UtYWxn2HUELHpodiuWEmeeyY/BRFiCJC4wQ2WOGugrq5oCZ3DQW9HsA7uxT
         03vBSNb02JFpcO1jKtZ+ojHvk8qjXIrBx1sm2Yk8U6SfQ8HtWpfPtw8aqnKaRYcYMsRI
         GglxzpCGbIZ7xjVe412FDNS7jp+R4hs1ORzhGvI7CfEsagLFhgSKKuSV2mUaQqTc8Jdr
         +l0O2OCSV8Trt32rjc+0QC9qouvhQyBQncAsVsbBktd6JD24HjgxGW+kb9aoHJ8jBWRT
         rmlB2XiAqQ7VAuU7NMFHcX0Lkwf0xKcu8KK9qOEU/bDHrq+6rhBlyQbj4VJ8G5BhjB6t
         gj/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@googlegroups.com header.s=20161025 header.b=BCDm0mNL;
       spf=pass (google.com: domain of ssarra123+noreply@googlegroups.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=SSARRA123+noreply@googlegroups.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=googlegroups.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id j21sor4210382otn.49.2019.02.12.23.11.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 23:11:09 -0800 (PST)
Received-SPF: pass (google.com: domain of ssarra123+noreply@googlegroups.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@googlegroups.com header.s=20161025 header.b=BCDm0mNL;
       spf=pass (google.com: domain of ssarra123+noreply@googlegroups.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=SSARRA123+noreply@googlegroups.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=googlegroups.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=googlegroups.com; s=20161025;
        h=mime-version:date:auto-submitted:message-id:subject:from:to;
        bh=lvcVrEvr7ANzwNdqlrmbwwWw2zDaYkh1BArZAgLt5Po=;
        b=BCDm0mNLbCFIzmOD167SXneru/XeDxvA9asVCIkPCGai/GSLKgarGmC/e2mEbZplsy
         Qx+XRYA+Ca7iNtJDi5Iy3Runnyycs1WGlXayUTI13yPAtzwUjhY4+o4iuPwRVi+kGyQu
         jwhKO/ZjrGOX1GYnZEdUsLNSwTgOJwKxgLM0IYtaLuSDK/nqNOiIeMdQ7WMtkopneXX5
         9L34iBiNOtX7BGCWoXOsrzPwhiBFD2QrADVJL2cCsfnt/cgAhZ5zAdR4yvN2g8f25sOx
         2G+aiU4bviDXBlfC0FIrUBBoXWTpoag+O6JneUw9cXsKJSCY6czQo3UKc0dYfNJwGYJh
         at2Q==
X-Google-Smtp-Source: AHgI3IZCT8T1lB98pwO7v4ADGOWF5mOFCWlGdwaKGq5qwsyrZP36mxse2WobJFElhdGVUz42U1i6JaUmcOSdrvfBBLPfFSmv8jw=
MIME-Version: 1.0
X-Received: by 2002:a05:6830:8b:: with SMTP id a11mr4328764oto.33.1550041868878;
 Tue, 12 Feb 2019 23:11:08 -0800 (PST)
Date: Tue, 12 Feb 2019 23:11:08 -0800
Auto-Submitted: auto-generated
X-Notifications: 870c1d020d000000
Message-ID: <7-xQIRXyKm4mw0INFXbv0A.0@notifications.google.com>
Subject: =?UTF-8?B?WW91IGhhdmUgYmVlbiBhZGRlZCB0byDYp9i22KfZgdmHNA==?=
From: =?UTF-8?B?2KfYttin2YHZhzQ=?= <SSARRA123+noreply@googlegroups.com>
To: linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="000000000000fb49380581c13e0d"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.430801, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000fb49380581c13e0d
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Content-Transfer-Encoding: base64

SGkgbGludXgtbW1Aa3ZhY2sub3JnLA0Kc3NzYXJhZWxhYmQxMjNAZ21haWwuY29tIGFkZGVkIHlv
dSB0byB0aGUg2KfYttin2YHZhzQgZ3JvdXAuDQpodHRwczovL2dyb3Vwcy5nb29nbGUuY29tL2Qv
Zm9ydW0vc3NhcnJhMTIzDQoNCk1lc3NhZ2UgZnJvbSBzc3NhcmFlbGFiZDEyM0BnbWFpbC5jb206
DQrZitiq2LTYsdmBINin2YTYp9iq2K3Yp9ivINin2YTYudix2KjZiSDZhNiq2YbZhdmK2Ycg2KfZ
hNmF2YjYp9ix2K8g2KfZhNio2LTYsdmK2Ycg2KjYr9i52YjZhyDYs9mK2KfYr9iq2YPZhSDZhNmE
2KfZhti22YXYp9mFINmE2YTZhdis2YXZiNi52YcNCg0KQWJvdXQgdGhpcyBncm91cDoNCtmK2KrY
tNix2YEg2KfZhNin2KrYrdin2K8g2KfZhNi52LHYqNmJINmE2KrZhtmF2YrZhyDYp9mE2YXZiNin
2LHYryDYp9mE2KjYtNix2YrZhyDYqNiv2LnZiNmHINiz2YrYp9iv2KrZg9mFINmE2YTYp9mG2LbZ
hdin2YUg2YTZhNmF2KzZhdmI2LnZhw0KDQpHb29nbGUgR3JvdXBzIGFsbG93cyB5b3UgdG8gY3Jl
YXRlIGFuZCBwYXJ0aWNpcGF0ZSBpbiBvbmxpbmUgZm9ydW1zIGFuZA0KZW1haWwtYmFzZWQgZ3Jv
dXBzIHdpdGggYSByaWNoIGNvbW11bml0eSBleHBlcmllbmNlLiBZb3UgY2FuIGFsc28gdXNlDQp5
b3VyIEdyb3VwIHRvIHNoYXJlIGRvY3VtZW50cywgcGljdHVyZXMsIGNhbGVuZGFycywgaW52aXRh
dGlvbnMsIGFuZCBvdGhlciAgDQpyZXNvdXJjZXMuDQoNCklmIHlvdSBkbyBub3Qgd2lzaCB0byBi
ZSBhIG1lbWJlciBvZiB0aGlzIGdyb3VwIG9yIGJlbGlldmUgdGhpcyBncm91cCBtYXkgIA0KY29u
dGFpbiBzcGFtOg0KKiBZb3UgY2FuIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBncm91cCBhdCAgDQpo
dHRwczovL2dyb3Vwcy5nb29nbGUuY29tL2QvZm9ydW0vc3NhcnJhMTIzL3Vuc3Vic2NyaWJlL0FI
WjdLVk53ZWMyTkkwSnhxRlNjYVNHaE9RTktxZ3RiN0t2Sl9hZVdudENZWU11VFJOTGJ0RnVjc0d6
NFJpRmVtRkF1X2JxNlU5RUVDWXZZSzl3Wi1iTnhwbm51VWtqYVZBICANCm9yIGJ5IHNlbmRpbmcg
ZW1haWwgdG8gU1NBUlJBMTIzK3Vuc3Vic2NyaWJlQGdvb2dsZWdyb3Vwcy5jb20NCiogWW91IGNh
biByZXBvcnQgdGhpcyBncm91cCBmb3IgYWJ1c2UgYXQgIA0KaHR0cHM6Ly9ncm91cHMuZ29vZ2xl
LmNvbS9kL2FidXNlL1lRQUFBTjhzNVJCZkFBQUEwb0ROV2ZrQUFBQXhfelUtbExfV1hqRHE4THh6
dVBLREo0Uk5fUm8NCiogWW91IGNhbiBvcHQgb3V0IG9mIGFsbCBmdXR1cmUgR29vZ2xlIEdyb3Vw
cyBhY3Rpdml0eSBhdCAgDQpodHRwczovL2dyb3Vwcy5nb29nbGUuY29tL2Qvb3B0b3V0DQoNClZp
ZXcgdGhpcyBncm91cCBhdDogaHR0cHM6Ly9ncm91cHMuZ29vZ2xlLmNvbS9kL2ZvcnVtL3NzYXJy
YTEyMw0KDQpTdGFydCB5b3VyIG93biBncm91cCBhdCBodHRwczovL2dyb3Vwcy5nb29nbGUuY29t
L2QvY3JlYXRlZ3JvdXAuDQpWaXNpdCBHb29nbGUgR3JvdXBzIEhlbHAgQ2VudGVyIGF0ICANCmh0
dHA6Ly9zdXBwb3J0Lmdvb2dsZS5jb20vZ3JvdXBzL2Jpbi9hbnN3ZXIucHk/YW5zd2VyPTQ2NjAx
Lg0K
--000000000000fb49380581c13e0d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html dir=3D"ltr"><head><meta charset=3D"UTF-8"></head><body><div dir=3D"lt=
r" style=3D"border:1px solid #f0f0f0;max-width:650px;font-family:Arial,sans=
-serif;color:#000000"><div style=3D"background-color:#f5f5f5;padding:10px 1=
2px"><table cellpadding=3D"0" cellspacing=3D"0" style=3D"width:100%"><tbody=
><tr><td style=3D"width:50%"><span style=3D"font:20px/24px arial;color:#333=
333"><a href=3D"https://groups.google.com/d/forum/ssarra123" style=3D"text-=
decoration:none; color: #000000">=D8=A7=D8=B6=D8=A7=D9=81=D9=874</a></span>=
</td><td style=3D"text-align:right;width:50%"><span style=3D"font:20px/24px=
 arial"><a style=3D"color:#dd4b39; text-decoration:none;" href=3D"https://g=
roups.google.com/d/overview" target=3D"_blank">Google Groups</a></span></td=
><td style=3D"text-align: right;"><a href=3D"https://groups.google.com/d/ov=
erview" target=3D"_blank"><img style=3D"border:0;vertical-align:middle;padd=
ing-left:10px;" src=3D"http://www.google.com/images/icons/product/groups-32=
.png" alt=3D'Logo for Google Groups'></a></td></tr></tbody></table></div><d=
iv style=3D"margin: 30px 30px 30px 30px; line-height: 21px;"><span style=3D=
"font-size: 13px; color: #333333;">Hi linux-mm@kvack.org,<br>sssaraelabd123=
@gmail.com added you to the <a href=3D"https://groups.google.com/d/forum/ss=
arra123" style=3D"color: #1155cc;text-decoration: none;"><b>=D8=A7=D8=B6=D8=
=A7=D9=81=D9=874</b></a> group.</span></div><div style=3D"margin: 30px 30px=
 30px 30px; line-height: 21px;"><span style=3D"font-size: 13px; color: #000=
000; font-weight:bold;">Message from sssaraelabd123@gmail.com</span><div><p=
 style=3D"font-size: 13px; color: #666666; padding: 10px 10px;background-co=
lor:#FAFAFA; border: 1px solid #DDDDDD; margin-top:0px;">=D9=8A=D8=AA=D8=B4=
=D8=B1=D9=81 =D8=A7=D9=84=D8=A7=D8=AA=D8=AD=D8=A7=D8=AF =D8=A7=D9=84=D8=B9=
=D8=B1=D8=A8=D9=89 =D9=84=D8=AA=D9=86=D9=85=D9=8A=D9=87 =D8=A7=D9=84=D9=85=
=D9=88=D8=A7=D8=B1=D8=AF =D8=A7=D9=84=D8=A8=D8=B4=D8=B1=D9=8A=D9=87 =D8=A8=
=D8=AF=D8=B9=D9=88=D9=87 =D8=B3=D9=8A=D8=A7=D8=AF=D8=AA=D9=83=D9=85 =D9=84=
=D9=84=D8=A7=D9=86=D8=B6=D9=85=D8=A7=D9=85 =D9=84=D9=84=D9=85=D8=AC=D9=85=
=D9=88=D8=B9=D9=87</p></div></div><div style=3D"margin: 30px 30px 30px 30px=
; line-height: 21px;"><span style=3D"font-size: 13px; color: #000000; font-=
weight:bold;">About this group</span><div><p style=3D"font-size: 13px; colo=
r: #666666; padding: 10px 10px;background-color:#FAFAFA; border: 1px solid =
#DDDDDD; margin-top:0px;">=D9=8A=D8=AA=D8=B4=D8=B1=D9=81 =D8=A7=D9=84=D8=A7=
=D8=AA=D8=AD=D8=A7=D8=AF =D8=A7=D9=84=D8=B9=D8=B1=D8=A8=D9=89 =D9=84=D8=AA=
=D9=86=D9=85=D9=8A=D9=87 =D8=A7=D9=84=D9=85=D9=88=D8=A7=D8=B1=D8=AF =D8=A7=
=D9=84=D8=A8=D8=B4=D8=B1=D9=8A=D9=87 =D8=A8=D8=AF=D8=B9=D9=88=D9=87 =D8=B3=
=D9=8A=D8=A7=D8=AF=D8=AA=D9=83=D9=85 =D9=84=D9=84=D8=A7=D9=86=D8=B6=D9=85=
=D8=A7=D9=85 =D9=84=D9=84=D9=85=D8=AC=D9=85=D9=88=D8=B9=D9=87</p></div></di=
v><div style=3D"margin: 30px 30px 30px 30px; line-height: 21px;"><p style=
=3D"font-size: 13px; color: #333333;">Google Groups allows you to create an=
d participate in online forums and email-based groups with a rich community=
 experience. You can also use your Group to share documents, pictures, cale=
ndars, invitations, and other resources. <a href=3D"https://support.google.=
com/groups/answer/46601?hl=3Den">Learn more</a>.</p><p style=3D"font-size: =
13px; color: #333333;">If you do not wish to be a member of this group you =
can send an email to <a style=3D"color: #1155cc;text-decoration: none;" hre=
f=3D"mailto:SSARRA123+unsubscribe@googlegroups.com">SSARRA123+unsubscribe@g=
ooglegroups.com</a> or follow this <a style=3D"color: #1155cc;text-decorati=
on: none;" href=3D"https://groups.google.com/d/forum/ssarra123/unsubscribe/=
AHZ7KVPAzvMML-2eGxOi4EL3p5Y9P5FM1WnsiikmCJc1U2ox3x1KLP89-2A9C3avI5t0-vB1t4p=
VSvP-_1yJ9yLa4TJ8kxhEyA">unsubscribe</a> link. If you believe this group ma=
y contain spam, you can also <a style=3D"color: #1155cc;text-decoration: no=
ne;" href=3D"https://groups.google.com/d/abuse/YQAAAN8s5RBfAAAA0oDNWfkAAAAx=
_zU-lL_WXjDq8LxzuPKDJ4RN_Ro">report</a> the group for abuse. For additional=
 information see our <a style=3D"color: #1155cc;text-decoration: none;" hre=
f=3D"http://support.google.com/groups/bin/answer.py?answer=3D46601">help ce=
nter</a>.</p></div><div style=3D"margin: 30px 30px 30px 30px; line-height: =
21px;"><a style=3D"border-radius:2px; display:inline-block;padding:0px 8px;=
background-color:#498af2;color:#ffffff;font-size:11px;border:solid 1px #307=
9ed; font-weight:bold;text-decoration:none;min-width: 54px;text-align:cente=
r;line-height:27px;" href=3D"https://groups.google.com/d/forum/ssarra123">V=
iew this group</a></div><div style=3D"margin: 30px 30px 30px 30px; line-hei=
ght: 21px;"><span style=3D"font-size: 13px; color: #333333;">If you do not =
wish to be added to Google Groups in the future you can opt out <a href=3D"=
https://groups.google.com/d/optout" style=3D"color: #1155cc;text-decoration=
: none;">here</a>.</span></div><div style=3D"background-color: #f5f5f5;padd=
ing: 5px 12px;"><table cellpadding=3D"0" cellspacing=3D"0" style=3D"width:1=
00%"><tbody><tr><td style=3D"padding-top:4px;font-family:arial,sans-serif;c=
olor:#636363;font-size:11px"><a href=3D"https://groups.google.com/d/createg=
roup" style=3D"color: #1155cc;text-decoration: none;" target=3D"_blank">Sta=
rt</a> a new group. <a href=3D"http://support.google.com/groups/bin/answer.=
py?answer=3D46601" style=3D"color: #1155cc;text-decoration: none;" target=
=3D"_blank">Visit</a> the help center.</td></tr></tbody></table></div></div=
></body></html>
--000000000000fb49380581c13e0d--

