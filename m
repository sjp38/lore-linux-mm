Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 018846B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 21:33:17 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 140-v6so2883919iou.14
        for <linux-mm@kvack.org>; Thu, 31 May 2018 18:33:16 -0700 (PDT)
Received: from mail-sh2.amlogic.com (mail-sh2.amlogic.com. [58.32.228.45])
        by mx.google.com with ESMTPS id s184-v6si8860755ios.22.2018.05.31.18.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 May 2018 18:33:15 -0700 (PDT)
Date: Fri, 1 Jun 2018 09:32:12 +0800
From: Tao.Zeng <Tao.Zeng@amlogic.com>
Reply-To: Tao.Zeng <Tao.Zeng@amlogic.com>
Subject: Re: Re: Report A bug of PTE attribute set for mprotect
References: <2018052919455555635434@amlogic.com>,
	<87tvqn96ro.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Message-ID: <2018060109321088618142@amlogic.com>
Content-Type: multipart/alternative;
	boundary="----=_001_NextPart334085347325_=----"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: mgorman <mgorman@suse.de>, tglx <tglx@linutronix.de>, "dan.j.williams" <dan.j.williams@intel.com>, "nadav.amit" <nadav.amit@gmail.com>, khandual <khandual@linux.vnet.ibm.com>, "zi.yan" <zi.yan@cs.rutgers.edu>, n-horiguchi <n-horiguchi@ah.jp.nec.com>, "henry.willard" <henry.willard@oracle.com>, jglisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

------=_001_NextPart334085347325_=----
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

RGVhciBQdW5pdCBBZ3Jhd2FsOg0KDQpZZXMsIEkgZmluZCBrZXJuZWwgZml4ZWQgaW50IGluOg0K
aHR0cDovLzEwLjguOS41L2tlcm5lbC9jb21tb24vY29tbWl0Lz9oPWFtbG9naWMtNC45LWRldiZp
ZD1lODZmMTVlZTY0ZDhlZTQ2MjU1ZDk2NGQ1NWY3NGY1YmE5YWY4YzM2DQoNClRoYW5rcyBmb3Ig
eW91ciBzdXBwb3J0IQ0KDQoNCg0KDQpUYW8uWmVuZw0KDQpGcm9tOiBQdW5pdCBBZ3Jhd2FsDQpE
YXRlOiAyMDE4LTA1LTMxIDIzOjM2DQpUbzogVGFvLlplbmcNCkNDOiBtZ29ybWFuOyB0Z2x4OyBk
YW4uai53aWxsaWFtczsgbmFkYXYuYW1pdDsga2hhbmR1YWw7IHppLnlhbjsgbi1ob3JpZ3VjaGk7
IGhlbnJ5LndpbGxhcmQ7IGpnbGlzc2U7IGxpbnV4LW1tOyBsaW51eC1rZXJuZWwNClN1YmplY3Q6
IFJlOiBSZXBvcnQgQSBidWcgb2YgUFRFIGF0dHJpYnV0ZSBzZXQgZm9yIG1wcm90ZWN0DQpUYW8u
WmVuZyA8VGFvLlplbmdAYW1sb2dpYy5jb20+IHdyaXRlczoNCg0KWy4uLl0NCg0KPiBCYWNrZ3Jv
dW5kIG9mIHRoaXMgcHJvYmxlbToNCg0KPiBPdXIga2VybmVsIHZlcnNpb24gaXMgMy4xNC4yOSwN
Cg0KQXJlIHlvdSBhYmxlIHRvIHJlcHJvZHVjZSB0aGUgcHJvYmxlbSBvbiBhIHJlY2VudCB1cHN0
cmVhbSBrZXJuZWw/DQoNCjMuMTQuMjkgaXMgbW9yZSB0aGFuIHRocmVlIHllYXJzIG9sZCBhbmQg
dGhlIHByb2JsZW0geW91IHNlZSBtaWdodCBoYXZlDQpiZWVuIGZpeGVkIHNpbmNlIHRoZW4uDQoN
ClRoYW5rcywNClB1bml0

------=_001_NextPart334085347325_=----
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><FMDATA content=3D""></FMDATA><FMDATA content=3D""></FMDATA>
<META content=3D"text/html; charset=3Dgb2312" http-equiv=3DContent-Type>
<STYLE>
BLOCKQUOTE {
	MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px; MARGIN-LEFT: 2em
}
OL {
	MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px
}
UL {
	MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px
}
BODY {
	FONT-SIZE: 10.5pt; FONT-FAMILY: &#23435; COLOR: #000000; LINE-HEIGHT: 1.5=
; 20307:=20
}
P {
	MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px
}
</STYLE>

<META name=3DGENERATOR content=3D"MSHTML 11.00.10570.1001"></HEAD>
<BODY style=3D"MARGIN: 10px">
<DIV style=3D"FONT-FAMILY: Courier New; COLOR: #000080">Dear <SPAN>Punit=20
Agrawal</SPAN>:</DIV>
<DIV style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Courier New">&nbsp;</DIV>
<DIV style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Courier New; TEXT-INDENT: 2em"=
>Yes, I=20
find kernel fixed int in:</DIV>
<DIV style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Courier New; TEXT-INDENT: 2em"=
>
<DIV><A=20
href=3D"http://10.8.9.5/kernel/common/commit/?h=3Damlogic-4.9-dev&amp;id=
=3De86f15ee64d8ee46255d964d55f74f5ba9af8c36">http://10.8.9.5/kernel/common=
/commit/?h=3Damlogic-4.9-dev&amp;id=3De86f15ee64d8ee46255d964d55f74f5ba9af=
8c36</A></DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks for your support!</DIV></DIV>
<DIV style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Courier New">&nbsp;</DIV>
<HR style=3D"HEIGHT: 1px; WIDTH: 210px" align=3Dleft color=3D#b5c4df SIZE=
=3D1>

<DIV><SPAN>Tao.Zeng</SPAN></DIV>
<DIV>&nbsp;</DIV>
<DIV=20
style=3D"BORDER-TOP: #b5c4df 1pt solid; BORDER-RIGHT: medium none; BORDER-=
BOTTOM: medium none; PADDING-BOTTOM: 0cm; PADDING-TOP: 3pt; PADDING-LEFT: =
0cm; BORDER-LEFT: medium none; PADDING-RIGHT: 0cm">
<DIV=20
style=3D"FONT-SIZE: 12px; BACKGROUND: #efefef; COLOR: #000000; PADDING-BOT=
TOM: 8px; PADDING-TOP: 8px; PADDING-LEFT: 8px; PADDING-RIGHT: 8px">
<DIV><B>From:</B>&nbsp;<A href=3D"mailto:punit.agrawal@arm.com">Punit=20
Agrawal</A></DIV>
<DIV><B>Date:</B>&nbsp;2018-05-31&nbsp;23:36</DIV>
<DIV><B>To:</B>&nbsp;<A href=3D"mailto:Tao.Zeng@amlogic.com">Tao.Zeng</A><=
/DIV>
<DIV><B>CC:</B>&nbsp;<A href=3D"mailto:mgorman@suse.de">mgorman</A>; <A=20
href=3D"mailto:tglx@linutronix.de">tglx</A>; <A=20
href=3D"mailto:dan.j.williams@intel.com">dan.j.williams</A>; <A=20
href=3D"mailto:nadav.amit@gmail.com">nadav.amit</A>; <A=20
href=3D"mailto:khandual@linux.vnet.ibm.com">khandual</A>; <A=20
href=3D"mailto:zi.yan@cs.rutgers.edu">zi.yan</A>; <A=20
href=3D"mailto:n-horiguchi@ah.jp.nec.com">n-horiguchi</A>; <A=20
href=3D"mailto:henry.willard@oracle.com">henry.willard</A>; <A=20
href=3D"mailto:jglisse@redhat.com">jglisse</A>; <A=20
href=3D"mailto:linux-mm@kvack.org">linux-mm</A>; <A=20
href=3D"mailto:linux-kernel@vger.kernel.org">linux-kernel</A></DIV>
<DIV><B>Subject:</B>&nbsp;Re: Report A bug of PTE attribute set for=20
mprotect</DIV></DIV></DIV>
<DIV>
<DIV>Tao.Zeng&nbsp;&lt;Tao.Zeng@amlogic.com&gt;&nbsp;writes:</DIV>
<DIV>&nbsp;</DIV>
<DIV>[...]</DIV>
<DIV>&nbsp;</DIV>
<DIV>&gt;&nbsp;Background&nbsp;of&nbsp;this&nbsp;problem:</DIV>
<DIV>&nbsp;</DIV>
<DIV>&gt;&nbsp;Our&nbsp;kernel&nbsp;version&nbsp;is&nbsp;3.14.29,</DIV>
<DIV>&nbsp;</DIV>
<DIV>Are&nbsp;you&nbsp;able&nbsp;to&nbsp;reproduce&nbsp;the&nbsp;problem&n=
bsp;on&nbsp;a&nbsp;recent&nbsp;upstream&nbsp;kernel?</DIV>
<DIV>&nbsp;</DIV>
<DIV>3.14.29&nbsp;is&nbsp;more&nbsp;than&nbsp;three&nbsp;years&nbsp;old&nb=
sp;and&nbsp;the&nbsp;problem&nbsp;you&nbsp;see&nbsp;might&nbsp;have</DIV>
<DIV>been&nbsp;fixed&nbsp;since&nbsp;then.</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks,</DIV>
<DIV>Punit</DIV>
<DIV>&nbsp;</DIV></DIV></BODY></HTML>

------=_001_NextPart334085347325_=------
