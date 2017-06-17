Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F23C76B0313
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 07:56:51 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id y134so52673925itc.14
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 04:56:51 -0700 (PDT)
Received: from www17.your-server.de (www17.your-server.de. [213.133.104.17])
        by mx.google.com with ESMTPS id e93si4579586iod.56.2017.06.17.04.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 04:56:50 -0700 (PDT)
References: <201706170814.FBlKIbl6%fengguang.wu@intel.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <201706170814.FBlKIbl6%fengguang.wu@intel.com>
Content-Type: multipart/signed;
	micalg=sha1;
	boundary=Apple-Mail-20CF6518-3FD1-40B0-8389-75AFA97F95D6;
	protocol="application/pkcs7-signature"
Content-Transfer-Encoding: 7bit
Message-Id: <816EAD4B-89D2-4F88-A920-BBCC640CFE16@m3y3r.de>
From: Thomas Meyer <thomas@m3y3r.de>
Subject: Re: [mmotm:master 230/317] arch/sparc/mm/extable.c:16:1: error: conflicting types for 'search_extable'
Date: Sat, 17 Jun 2017 13:56:46 +0200
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--Apple-Mail-20CF6518-3FD1-40B0-8389-75AFA97F95D6
Content-Type: multipart/alternative;
	boundary=Apple-Mail-30D85851-85A4-41B2-98E3-44FB18625BB5
Content-Transfer-Encoding: 7bit


--Apple-Mail-30D85851-85A4-41B2-98E3-44FB18625BB5
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable


> Am 17.06.2017 um 02:07 schrieb kbuild test robot <fengguang.wu@intel.com>:=

>=20
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   8c91e2a1ea04c0c1e29415c62f151e77de2291f8
> commit: ad8aa0a41610e2b5225067c38a9020f6def8a940 [230/317] lib/extable.c: u=
se bsearch() library function in search_extable()
> config: sparc-defconfig (attached as .config)
> compiler: sparc-linux-gcc (GCC) 6.2.0
> reproduce:
>        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/=
make.cross -O ~/bin/make.cross
>        chmod +x ~/bin/make.cross
>        git checkout ad8aa0a41610e2b5225067c38a9020f6def8a940
>        # save the attached .config to linux build tree
>        make.cross ARCH=3Dsparc=20
>=20
> All errors (new ones prefixed by >>):
>=20
>>> arch/sparc/mm/extable.c:16:1: error: conflicting types for 'search_extab=
le'
>    search_extable(const struct exception_table_entry *start,
>    ^~~~~~~~~~~~~~
>   In file included from arch/sparc/mm/extable.c:6:0:
>   include/linux/extable.h:11:1: note: previous declaration of 'search_exta=
ble' was here
>    search_extable(const struct exception_table_entry *first,
>    ^~~~~~~~~~~~~~

Oops, of course I only did test against x86_64...

But one question regarding the range entries:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch=
/sparc/mm/extable.c#n60

Shouldn't the range search skip deleted entries? Or does something else ensu=
re consistency?

I'll check all other archs for arch-specific implementation and send v3 then=
.

Sorry for the fuss and kind regards
Thomas=20

>=20
> vim +/search_extable +16 arch/sparc/mm/extable.c
>=20
> ^1da177e Linus Torvalds 2005-04-16  10            struct exception_table_e=
ntry *finish)
> ^1da177e Linus Torvalds 2005-04-16  11  {
> ^1da177e Linus Torvalds 2005-04-16  12  }
> ^1da177e Linus Torvalds 2005-04-16  13 =20
> ^1da177e Linus Torvalds 2005-04-16  14  /* Caller knows they are in a rang=
e if ret->fixup =3D=3D 0 */
> ^1da177e Linus Torvalds 2005-04-16  15  const struct exception_table_entry=
 *
> ^1da177e Linus Torvalds 2005-04-16 @16  search_extable(const struct except=
ion_table_entry *start,
> ^1da177e Linus Torvalds 2005-04-16  17             const struct exception_=
table_entry *last,
> ^1da177e Linus Torvalds 2005-04-16  18             unsigned long value)
> ^1da177e Linus Torvalds 2005-04-16  19  {
>=20
> :::::: The code at line 16 was first introduced by commit
> :::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2
>=20
> :::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
> :::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>
>=20
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Cen=
ter
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporat=
ion
> <.config.gz>

--Apple-Mail-30D85851-85A4-41B2-98E3-44FB18625BB5
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charset=3D=
utf-8"></head><body dir=3D"auto"><div><br></div><div>Am 17.06.2017 um 02:07 s=
chrieb kbuild test robot &lt;<a href=3D"mailto:fengguang.wu@intel.com">fengg=
uang.wu@intel.com</a>&gt;:<br><br></div><blockquote type=3D"cite"><div><span=
>tree: &nbsp;&nbsp;git://git.cmpxchg.org/linux-mmotm.git master</span><br><s=
pan>head: &nbsp;&nbsp;8c91e2a1ea04c0c1e29415c62f151e77de2291f8</span><br><sp=
an>commit: ad8aa0a41610e2b5225067c38a9020f6def8a940 [230/317] lib/extable.c:=
 use bsearch() library function in search_extable()</span><br><span>config: s=
parc-defconfig (attached as .config)</span><br><span>compiler: sparc-linux-g=
cc (GCC) 6.2.0</span><br><span>reproduce:</span><br><span> &nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;wget <a href=3D"https://raw.githubusercontent.com/0=
1org/lkp-tests/master/sbin/make.cross">https://raw.githubusercontent.com/01o=
rg/lkp-tests/master/sbin/make.cross</a> -O ~/bin/make.cross</span><br><span>=
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;chmod +x ~/bin/make.cross</span><=
br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;git checkout ad8aa0a4161=
0e2b5225067c38a9020f6def8a940</span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;# save the attached .config to linux build tree</span><br><span=
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;make.cross ARCH=3Dsparc </span><=
br><span></span><br><span>All errors (new ones prefixed by &gt;&gt;):</span>=
<br><span></span><br><blockquote type=3D"cite"><blockquote type=3D"cite"><sp=
an>arch/sparc/mm/extable.c:16:1: error: conflicting types for 'search_extabl=
e'</span><br></blockquote></blockquote><span> &nbsp;&nbsp;&nbsp;search_extab=
le(const struct exception_table_entry *start,</span><br><span> &nbsp;&nbsp;&=
nbsp;^~~~~~~~~~~~~~</span><br><span> &nbsp;&nbsp;In file included from arch/=
sparc/mm/extable.c:6:0:</span><br><span> &nbsp;&nbsp;include/linux/extable.h=
:11:1: note: previous declaration of 'search_extable' was here</span><br><sp=
an> &nbsp;&nbsp;&nbsp;search_extable(const struct exception_table_entry *fir=
st,</span><br><span> &nbsp;&nbsp;&nbsp;^~~~~~~~~~~~~~</span><br></div></bloc=
kquote><div><br></div>Oops, of course I only did test against x86_64...<div>=
<br></div><div>But one question regarding the range entries:</div><div><a hr=
ef=3D"https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tre=
e/arch/sparc/mm/extable.c#n60">https://git.kernel.org/pub/scm/linux/kernel/g=
it/torvalds/linux.git/tree/arch/sparc/mm/extable.c#n60</a></div><div><br></d=
iv><div>Shouldn't the range search skip deleted entries? Or does something e=
lse ensure consistency?</div><div><br></div><div>I'll check all other archs f=
or arch-specific implementation and send v3 then.</div><div><br></div><div>S=
orry for the fuss and kind regards</div><div>Thomas&nbsp;</div><div><br><blo=
ckquote type=3D"cite"><div><span></span><br><span>vim +/search_extable +16 a=
rch/sparc/mm/extable.c</span><br><span></span><br><span>^1da177e Linus Torva=
lds 2005-04-16 &nbsp;10 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;struct exce=
ption_table_entry *finish)</span><br><span>^1da177e Linus Torvalds 2005-04-1=
6 &nbsp;11 &nbsp;{</span><br><span>^1da177e Linus Torvalds 2005-04-16 &nbsp;=
12 &nbsp;}</span><br><span>^1da177e Linus Torvalds 2005-04-16 &nbsp;13 &nbsp=
;</span><br><span>^1da177e Linus Torvalds 2005-04-16 &nbsp;14 &nbsp;/* Calle=
r knows they are in a range if ret-&gt;fixup =3D=3D 0 */</span><br><span>^1d=
a177e Linus Torvalds 2005-04-16 &nbsp;15 &nbsp;const struct exception_table_=
entry *</span><br><span>^1da177e Linus Torvalds 2005-04-16 @16 &nbsp;search_=
extable(const struct exception_table_entry *start,</span><br><span>^1da177e L=
inus Torvalds 2005-04-16 &nbsp;17 &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;const struct exception_table_entry *last,</span><br><span>^1d=
a177e Linus Torvalds 2005-04-16 &nbsp;18 &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;unsigned long value)</span><br><span>^1da177e Linus To=
rvalds 2005-04-16 &nbsp;19 &nbsp;{</span><br><span></span><br><span>:::::: T=
he code at line 16 was first introduced by commit</span><br><span>:::::: 1da=
177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2</span><br><span></spa=
n><br><span>:::::: TO: Linus Torvalds &lt;<a href=3D"mailto:torvalds@ppc970.=
osdl.org">torvalds@ppc970.osdl.org</a>&gt;</span><br><span>:::::: CC: Linus T=
orvalds &lt;<a href=3D"mailto:torvalds@ppc970.osdl.org">torvalds@ppc970.osdl=
.org</a>&gt;</span><br><span></span><br><span>---</span><br><span>0-DAY kern=
el test infrastructure &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Open Source Technology Center</span><br=
><span><a href=3D"https://lists.01.org/pipermail/kbuild-all">https://lists.0=
1.org/pipermail/kbuild-all</a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Intel Corpora=
tion</span><br></div></blockquote><blockquote type=3D"cite"><div>&lt;.config=
.gz&gt;</div></blockquote></div></body></html>=

--Apple-Mail-30D85851-85A4-41B2-98E3-44FB18625BB5--

--Apple-Mail-20CF6518-3FD1-40B0-8389-75AFA97F95D6
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Disposition: attachment;
	filename=smime.p7s
Content-Transfer-Encoding: base64

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
PeLMnEm7tRjvT6lNp81SDvaRGPbrU4BZ1k/FGHiV+XitX0bypL12DS64bKo8OEgN4IMYYg3dXg9u
+gpn0rc8/l7AUrKUk0IlcvKrnvhNpxQ3xWxr7YeYANUny6Z5XVgLAkgaLmbF6J7Dl1VuAxjTve2S
1k2PNUQ/dnJmNCCR/bjjqTW69An093a5Z7/zrgunfPWQCNXtTtfKkQlPSVplOasg1m47e7uBj4bF
dNvBwZ641Aev4xEKqg9WMMK3Vy03LmbZa0IK48Vg1FP4XDmZeqBRKAooVbb5iQIDAQABo4IBbTCC
AWkwGgYDVR0RBBMwEYEPdGhvbWFzQG0zeTNyLmRlMA4GA1UdDwEB/wQEAwIGwDATBgNVHSUEDDAK
BggrBgEFBQcDBDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vdm9sa3N2ZXJzY2hsdWVzc2VsdW5n
LmRlL2NybC9wcml2YXRlY2EuY3JsMH4GCCsGAQUFBwEBBHIwcDA8BggrBgEFBQcwAoYwaHR0cDov
L3ZvbGtzdmVyc2NobHVlc3NlbHVuZy5kZS9jYS9wcml2YXRlY2EuY3J0MDAGCCsGAQUFBzABhiRo
dHRwOi8vb2NzcC52b2xrc3ZlcnNjaGx1ZXNzZWx1bmcuZGUwFAYDVR0gBA0wCzAJBgcrJA8JAQEB
MB0GA1UdDgQWBBQ6nNQ4hduFPYI2tI0+IcC/wTZSSDAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaA
FEJzCOU+QLR+x4VXEHf9EQ9FhKfdMA0GCSqGSIb3DQEBCwUAA4ICAQCDrepf05Bm93sh+Db4Vgee
W2GweWJDGhHj1vuWowuaXoRgSz0G+QQWs4OBljzU9e6/W63jFrXqCM495tS4LbpcRqNzvN8mVEuF
8mYw9ZM7YG9Nx+Y3Pt7IDrOgWpw8hmEFNAfb8/dTMaMDHkPGYqLOvJA2rgk8rK5eJ2cSZ3TFAc5Z
lz/Tq1PB59Jl/nzIabBo6x7tvhjiqSL/R0fg/oi9nRvevNrCEWe/JjBoOST51HWV/91PaasDLEG/
OFG1lWsy7m0kYx4mHgxlsRVznIE9V1IguNi+1bY2k44mRNscufUNgVezto4JBARIEuLhFgIXQ8Vv
5r0ynhpsDtIfuI/NejqUlenSNe99FssF0GOluZ6qovSLb+f5GcLhcEf8OV0tUaAhEryL5w7rh4Hq
ca1IZ1OxDkTNxgQVOr9qihZhQblH6HWYzi3C2nFvWdVqcQV+ZAppZqF7HD1A23FiFOter5V5CDy8
19dZc9Dwu0MowmVZiOlh2mhPk1ID2vCSGtM2KGq/ZnJH9gnjzN3B0WJg0dmVQdtggCgj4Caq7f4V
tY9K1oIIyIuo6mpjBk+LFtgI+kWdDpsU6fzEyq3PmTW/0/cYzI1kJvUztj+0AHNyCBij4F3Yf3mi
Ob88vCPJPZg6Rhry9hxwX13zHbEE6FfiWRcxWihkwFXmEckbUR5YFDCCBoIwggRqoAMCAQICCA7P
iiLFnseHMA0GCSqGSIb3DQEBCwUAME4xJjAkBgNVBAMMHVZvbGtzdmVyc2NobHVlc3NlbHVuZyBS
b290IENBMRcwFQYDVQQKDA5GcmF1bmhvZmVyIFNJVDELMAkGA1UEBhMCREUwHhcNMTYwNTA5MTQw
OTEzWhcNMjEwNTEwMTQwOTEzWjBRMSkwJwYDVQQDDCBWb2xrc3ZlcnNjaGx1ZXNzZWx1bmcgUHJp
dmF0ZSBDQTEXMBUGA1UECgwORnJhdW5ob2ZlciBTSVQxCzAJBgNVBAYTAkRFMIICIjANBgkqhkiG
9w0BAQEFAAOCAg8AMIICCgKCAgEAzNfyQJBPr3f99kqZCdW9r9U2EKFTXg6IuLh8LWKsZHo8XiRE
BarheOkdxdSKW9FTUEZUdwWk1uwpuDYnIfEcKrTAOiItrdRJc98h2yhD6tlZgSLY/B9Vjw2LQIZZ
WVnsYVvBOxYznfaveDY7HfowbXgERxv30sQqNZP+KhUB3JjQ1pVAVyLZxK+j8a7k1bFH955kkJ6G
+AoTzZzHj5Bn9LUTFvP7RsB2rNPy+GBZ52EvdlqrGEi7JKvM9M8jffA6RZ8OzXS1utng5jWj+efw
Hg5Wr4JC3YZs/TpNogPVyw4vDjCF/RI56mrSUQBXm1IVjuWM8qUhphBR2gRZN0sATWCj8pWG1pLl
Mz02Ddg/AbZ7V9C6MwH4I6nGQ1XxhNSkWSrUQUnXYrOoA8T0IH/6AuY7ukMrj+KLJtTlM1Y+sOXR
Zyk/QFSgVP/5AbT82ErsVZW1q7JDLkaEdwrPDFXQNqfrlIsYI3FYrgB6rVJG3tZ/3LMmFHNQVnTX
hCiy6mUFpogdAl1QxXeNMWAdVLMBBm/iY9IZwtqb9G/Gxt19QmHLpLwyo4nVX1F7Got+yLYzfrLf
0toMk3Kjj7uhlndhpkoeFwDKMioi1dsUn3zxRK6dwaPzkKsphj8ybXFBr3s68A4+xKmaQxR7gcg9
tPKB/pTyC8vtkAl1lfNU14IV2ikCAwEAAaOCAV8wggFbMEkGCCsGAQUFBwEBBD0wOzA5BggrBgEF
BQcwAoYtaHR0cDovL3ZvbGtzdmVyc2NobHVlc3NlbHVuZy5kZS9jYS9yb290Y2EuY3J0MB0GA1Ud
DgQWBBRCcwjlPkC0fseFVxB3/REPRYSn3TASBgNVHRMBAf8ECDAGAQH/AgEAMB8GA1UdIwQYMBaA
FBeNp8XO7dqGdP5+TYW2xuL7R78PMBEGA1UdIAQKMAgwBgYEVR0gADCBlgYDVR0fBIGOMIGLMIGI
oDKgMIYuaHR0cDovL3ZvbGtzdmVyc2NobHVlc3NlbHVuZy5kZS9jcmwvcm9vdGNhLmNybKJSpFAw
TjEmMCQGA1UEAwwdVm9sa3N2ZXJzY2hsdWVzc2VsdW5nIFJvb3QgQ0ExFzAVBgNVBAoMDkZyYXVu
aG9mZXIgU0lUMQswCQYDVQQGEwJERTAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQELBQADggIB
AFlX5ruAA0T3RL9Z+NQo7syDNwv3n1p1eSIloJlKGkIlHdNUJNxfjvzpLvm1n47sUsbHlZOW7MDK
P2ODo94i5yHKEB2TPQF4NMJBsiH60xQuFQDgKd5nawBOgs1hVJR0ijGlMipwrYwfdNvyrXCHGew0
PDuRcRa53VRR3vE1vxhHYpbyPOdq3s2Q+TfvF3ihr+WkvujnSQocg65bY/Tj4+ARjdt1odI4HzHw
gDPc3SfUPgOEedte23oU8Y2LRpKpb9eHeb0hH32hQ+QOToULISE42ymiG5MOi4hxKUUZrGIK+BQ9
r/dABOsbskFA7j7rL/k5+v2j73oLals47S1BRHsIU3pX7K5XfVnDTVu5vSlLCjEV+C9pqHv0pDB5
fhQb6ZImjWJfkFdvFry+EYbbpogMr+seUytfUmd+8cz05d1ncTUN926iiY6AGxSKCRvHbrtQdVFJ
IX4jlKIpnDg4DH9Xlatlr/K/zNAIxiiNXrQND+UmhEgf2Rb0Ba3whIc9moXGQEjZdrt4qLJjtccq
OcOgvNszFuFIvhzpdH69+twIZtM4fBP1AjVfRxRhhNmAzz701bcAGv2vRgYURHsQ+GoedTGnhgAi
WjwSoIkQlD7mjjB7/ayUWCCbQ4AW0/Wjja2B9ahRQkQwSn3F1eBeuXRHM5Jk54/yq6uT7rnZG93n
MYICwzCCAr8CAQEwXTBRMSkwJwYDVQQDDCBWb2xrc3ZlcnNjaGx1ZXNzZWx1bmcgUHJpdmF0ZSBD
QTEXMBUGA1UECgwORnJhdW5ob2ZlciBTSVQxCzAJBgNVBAYTAkRFAggSgbEVWeufUzAJBgUrDgMC
GgUAoIIBOzAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNzA2MTcx
MTU2NDdaMCMGCSqGSIb3DQEJBDEWBBRrGLQ3TsjMRWauxfAhSEOfRc75BzBsBgkrBgEEAYI3EAQx
XzBdMFExKTAnBgNVBAMMIFZvbGtzdmVyc2NobHVlc3NlbHVuZyBQcml2YXRlIENBMRcwFQYDVQQK
DA5GcmF1bmhvZmVyIFNJVDELMAkGA1UEBhMCREUCCBKBsRVZ659TMG4GCyqGSIb3DQEJEAILMV+g
XTBRMSkwJwYDVQQDDCBWb2xrc3ZlcnNjaGx1ZXNzZWx1bmcgUHJpdmF0ZSBDQTEXMBUGA1UECgwO
RnJhdW5ob2ZlciBTSVQxCzAJBgNVBAYTAkRFAggSgbEVWeufUzANBgkqhkiG9w0BAQEFAASCAQBN
0h+9ukMC5iTqIIfO7d3IEU+KhxOf5n9E2tLuXoCLVHhz5A2IRT0cA0gkp0xp0u1cS8eNltFwCPjO
L2ZcrdXxhDyOvrk4vqwCAIhTlrOAQfsDZguyUH2ULBpnX+eDxuH1xOboRXs5hY7noMNV82aNe50y
CkD6R5k55VcbYU0+t2acx0IFRn8+DHNfmnrLff3BmBhRlqqFg5FT3Wj1K1bDxRRE76uaodkTtczX
rwajgKit5GZqKYr8ESMSOJJv3XV4A57Yv8n8pOtaT+lJLmiwog35/hq6KzXQzsq0coKoOZcxbsaF
81M0IxEG8a8AVyDyYbvKofCqtFlQoy4P1VtMAAAAAAAA
--Apple-Mail-20CF6518-3FD1-40B0-8389-75AFA97F95D6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
