Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id E7D5A6B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 08:20:31 -0400 (EDT)
From: Shawn Joo <sjoo@nvidia.com>
Date: Thu, 2 Aug 2012 20:20:25 +0800
Subject: [question] how to increase the number of object on cache?
Message-ID: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEEHKMAIL02nvidi_"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEEHKMAIL02nvidi_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Dear Experts,

I would like to know a mechanism, how to increase the number of object an=
d where the memory is from.

(because when cache is created by "kmem_cache_create", there is only obje=
ct size, but no number of the object)
For example, "size-65536" does not have available memory from below dump.=

In that state, if memory allocation is requested to "size-65536",

1.     How to allocate/increase the number of object on "size-65536"?

2.     Where is the new allocated memory from? (from buddy?)

I believe it is hard to explain with simple word, any advice will be very=
=20helpful.

cat /proc/buddyinfo
Node 0, zone   Normal    949      0      0      2      3      3      0   =
=20  0      1      1      0

cat /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesp=
erslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active=
_slabs> <num_slabs> <sharedavail>
size-4194304           0      0 4194304    1 1024 : tunables    1    1   =
=200 : slabdata      0      0      0
size-2097152           0      0 2097152    1  512 : tunables    1    1   =
=200 : slabdata      0      0      0
size-1048576           0      0 1048576    1  256 : tunables    1    1   =
=200 : slabdata      0      0      0
size-524288            0      0 524288    1  128 : tunables    1    1    =
0 : slabdata      0      0      0
size-262144            0      0 262144    1   64 : tunables    1    1    =
0 : slabdata      0      0      0
size-131072            1      1 131072    1   32 : tunables    8    4    =
0 : slabdata      1      1      0
size-65536             4      4  65536    1   16 : tunables    8    4    =
0 : slabdata      4      4      0




Thanks,
Seongho(Shawn)


-------------------------------------------------------------------------=
----------
This email message is for the sole use of the intended recipient(s) and m=
ay contain
confidential information.  Any unauthorized review, use, disclosure or di=
stribution
is prohibited.  If you are not the intended recipient, please contact the=
=20sender by
reply email and destroy all copies of the original message.
-------------------------------------------------------------------------=
----------

--_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEEHKMAIL02nvidi_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-mi=
crosoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:wo=
rd" xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D=
"http://www.w3.org/TR/REC-html40"><head><meta http-equiv=3DContent-Type c=
ontent=3D"text/html; charset=3Dus-ascii"><meta name=3DGenerator content=3D=
"Microsoft Word 14 (filtered medium)"><style><!--
/* Font Definitions */
@font-face
=09{font-family:"Malgun Gothic";
=09panose-1:2 11 5 3 2 0 0 2 0 4;}
@font-face
=09{font-family:Calibri;
=09panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
=09{font-family:"Malgun Gothic";
=09panose-1:2 11 5 3 2 0 0 2 0 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
=09{margin:0cm;
=09margin-bottom:.0001pt;
=09font-size:11.0pt;
=09font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
=09{mso-style-priority:99;
=09color:blue;
=09text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
=09{mso-style-priority:99;
=09color:purple;
=09text-decoration:underline;}
p.MsoPlainText, li.MsoPlainText, div.MsoPlainText
=09{mso-style-priority:99;
=09mso-style-link:"Plain Text Char";
=09margin:0cm;
=09margin-bottom:.0001pt;
=09font-size:10.0pt;
=09font-family:"Malgun Gothic";}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
=09{mso-style-priority:34;
=09margin-top:0cm;
=09margin-right:0cm;
=09margin-bottom:0cm;
=09margin-left:36.0pt;
=09margin-bottom:.0001pt;
=09font-size:11.0pt;
=09font-family:"Calibri","sans-serif";}
span.PlainTextChar
=09{mso-style-name:"Plain Text Char";
=09mso-style-priority:99;
=09mso-style-link:"Plain Text";
=09font-family:"Malgun Gothic";}
span.EmailStyle20
=09{mso-style-type:personal-compose;
=09font-family:"Malgun Gothic";
=09color:windowtext;}
.MsoChpDefault
=09{mso-style-type:export-only;
=09font-size:10.0pt;
=09font-family:"Calibri","sans-serif";}
@page WordSection1
=09{size:612.0pt 792.0pt;
=09margin:3.0cm 72.0pt 72.0pt 72.0pt;}
div.WordSection1
=09{page:WordSection1;}
/* List Definitions */
@list l0
=09{mso-list-id:1481730604;
=09mso-list-type:hybrid;
=09mso-list-template-ids:-561091614 67698703 67698713 67698715 67698703 6=
7698713 67698715 67698703 67698713 67698715;}
@list l0:level1
=09{mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level2
=09{mso-level-number-format:alpha-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level3
=09{mso-level-number-format:roman-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:right;
=09text-indent:-9.0pt;}
@list l0:level4
=09{mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level5
=09{mso-level-number-format:alpha-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level6
=09{mso-level-number-format:roman-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:right;
=09text-indent:-9.0pt;}
@list l0:level7
=09{mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level8
=09{mso-level-number-format:alpha-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level9
=09{mso-level-number-format:roman-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:right;
=09text-indent:-9.0pt;}
ol
=09{margin-bottom:0cm;}
ul
=09{margin-bottom:0cm;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]--></head><body lang=3DEN-US link=3Dblue v=
link=3Dpurple><div class=3DWordSection1><p class=3DMsoNormal><span style=3D=
'font-size:10.0pt;font-family:"Malgun Gothic"'>Dear Experts,<o:p></o:p></=
span></p><p class=3DMsoNormal><span style=3D'font-size:10.0pt;font-family=
:"Malgun Gothic"'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal><span =
style=3D'font-size:10.0pt;font-family:"Malgun Gothic"'>I would like to kn=
ow a mechanism, how to increase the number of object and where the memory=
=20is from.<o:p></o:p></span></p><p class=3DMsoPlainText>(because when ca=
che is created by &quot;kmem_cache_create&quot;, there is only object siz=
e, but no number of the object)<o:p></o:p></p><p class=3DMsoNormal><span =
style=3D'font-size:10.0pt;font-family:"Malgun Gothic"'>For example, <span=
=20lang=3DKO>&#8220;</span><span style=3D'background:aqua;mso-highlight:a=
qua'>size-65536</span><span lang=3DKO>&#8221; </span>does not have availa=
ble memory from below dump.<o:p></o:p></span></p><p class=3DMsoNormal><sp=
an style=3D'font-size:10.0pt;font-family:"Malgun Gothic"'>In that state, =
if memory allocation is requested to <span lang=3DKO>&#8220;</span><span =
style=3D'background:aqua;mso-highlight:aqua'>size-65536</span><span lang=3D=
KO>&#8221;</span>, <o:p></o:p></span></p><p class=3DMsoListParagraph styl=
e=3D'text-indent:-18.0pt;mso-list:l0 level1 lfo2'><![if !supportLists]><s=
pan style=3D'font-size:10.0pt;font-family:"Malgun Gothic"'><span style=3D=
'mso-list:Ignore'>1.<span style=3D'font:7.0pt "Times New Roman"'>&nbsp;&n=
bsp;&nbsp;&nbsp; </span></span></span><![endif]><span style=3D'font-size:=
10.0pt;font-family:"Malgun Gothic"'>How to allocate/increase the number o=
f object on <span lang=3DKO>&#8220;</span>size-65536<span lang=3DKO>&#822=
1;</span>?<o:p></o:p></span></p><p class=3DMsoListParagraph style=3D'text=
-indent:-18.0pt;mso-list:l0 level1 lfo2'><![if !supportLists]><span style=
=3D'font-size:10.0pt;font-family:"Malgun Gothic"'><span style=3D'mso-list=
:Ignore'>2.<span style=3D'font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp=
;&nbsp; </span></span></span><![endif]><span style=3D'font-size:10.0pt;fo=
nt-family:"Malgun Gothic"'>Where is the new allocated memory from? (from =
buddy?)<o:p></o:p></span></p><p class=3DMsoNormal><span style=3D'font-siz=
e:10.0pt;font-family:"Malgun Gothic"'><o:p>&nbsp;</o:p></span></p><p clas=
s=3DMsoNormal><span style=3D'font-size:10.0pt;font-family:"Malgun Gothic"=
'>I believe it is hard to explain with simple word, any advice will be ve=
ry helpful.<o:p></o:p></span></p><p class=3DMsoNormal><span style=3D'font=
-size:10.0pt;font-family:"Malgun Gothic";color:#1F497D'><o:p>&nbsp;</o:p>=
</span></p><table class=3DMsoNormalTable border=3D0 cellspacing=3D0 cellp=
adding=3D0 style=3D'border-collapse:collapse'><tr><td width=3D638 valign=3D=
top style=3D'width:478.8pt;border:solid windowtext 1.0pt;padding:0cm 5.4p=
t 0cm 5.4pt'><p class=3DMsoNormal><span style=3D'font-size:8.0pt;font-fam=
ily:"Malgun Gothic"'>cat /proc/buddyinfo</span><span style=3D'font-size:8=
.0pt;font-family:"Malgun Gothic"'><o:p></o:p></span></p><p class=3DMsoNor=
mal><span style=3D'font-size:8.0pt;font-family:"Malgun Gothic"'>Node 0, z=
one&nbsp;&nbsp; Normal&nbsp;&nbsp;&nbsp; 949&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span s=
tyle=3D'background:aqua;mso-highlight:aqua'>2 </span><span style=3D'backg=
round:yellow;mso-highlight:yellow'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0</span><o:p></o:p></span></p><p cl=
ass=3DMsoNormal><span style=3D'font-size:8.0pt;font-family:"Malgun Gothic=
"'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal><span style=3D'font-s=
ize:8.0pt;font-family:"Malgun Gothic"'>cat /proc/slabinfo<o:p></o:p></spa=
n></p><p class=3DMsoNormal><span style=3D'font-size:8.0pt;font-family:"Ma=
lgun Gothic"'>slabinfo - version: 2.1<o:p></o:p></span></p><p class=3DMso=
Normal><span style=3D'font-size:8.0pt;font-family:"Malgun Gothic"'># name=
&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;ac=
tive_objs&gt; &lt;<span style=3D'background:yellow;mso-highlight:yellow'>=
num_objs</span>&gt; &lt;objsize&gt; &lt;objperslab&gt; &lt;pagesperslab&g=
t; : tunables &lt;limit&gt; &lt;batchcount&gt; &lt;sharedfactor&gt; : sla=
bdata &lt;active_slabs&gt; &lt;num_slabs&gt; &lt;sharedavail&gt;<o:p></o:=
p></span></p><p class=3DMsoNormal><span style=3D'font-size:8.0pt;font-fam=
ily:"Malgun Gothic"'>size-4194304&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 4194304&nbsp;&nbsp=
;&nbsp; 1 1024 : tunables&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; 1&nbsp;&n=
bsp;&nbsp; 0 : slabdata&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<o:p></o:p></span></p><p cl=
ass=3DMsoNormal><span style=3D'font-size:8.0pt;font-family:"Malgun Gothic=
"'>size-2097152&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 2097152&nbsp;&nbsp;&nbsp; 1&nbsp; 51=
2 : tunables&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; 0 =
: slabdata&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<o:p></o:p></span></p><p class=3DMsoNorm=
al><span style=3D'font-size:8.0pt;font-family:"Malgun Gothic"'>size-10485=
76&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;0&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 0 1048576&nbsp;&nbsp;&nbsp; 1&nbsp; 256 : tunables&=
nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; 0 : slabdata&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; 0<o:p></o:p></span></p><p class=3DMsoNormal><span styl=
e=3D'font-size:8.0pt;font-family:"Malgun Gothic"'>size-524288&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; 0 524288&nbsp;&nbsp;&nbsp; 1&nbsp; 128 : tunables&nbsp;&nbs=
p;&nbsp; 1&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; 0 : slabdata&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; 0<o:p></o:p></span></p><p class=3DMsoNormal><span style=3D'font=
-size:8.0pt;font-family:"Malgun Gothic"'>size-262144&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; 0 262144&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; 64 : tunables&nbsp;&nbsp;&n=
bsp; 1&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp; 0 : slabdata&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 0<o:p></o:p></span></p><p class=3DMsoNormal><span style=3D'font-siz=
e:8.0pt;font-family:"Malgun Gothic"'>size-131072&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style=3D'background:yello=
w;mso-highlight:yellow'>1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1</span> 131072&n=
bsp;&nbsp;&nbsp; 1&nbsp;&nbsp; 32 : tunables&nbsp;&nbsp;&nbsp; 8&nbsp;&nb=
sp;&nbsp; 4&nbsp;&nbsp;&nbsp; 0 : slabdata&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<o:p></o=
:p></span></p><p class=3DMsoNormal><span style=3D'font-size:8.0pt;font-fa=
mily:"Malgun Gothic";background:aqua;mso-highlight:aqua'>size-65536</span=
><span style=3D'font-size:8.0pt;font-family:"Malgun Gothic"'>&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style=3D=
'background:yellow;mso-highlight:yellow'>4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
4</span>&nbsp; 65536&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; 16 : tunables&nbsp;&=
nbsp;&nbsp; 8&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp; 0 : slabdata&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; 0</span><span style=3D'font-size:10.0pt;font-family:"Malgun =
Gothic"'><o:p></o:p></span></p></td></tr></table><p class=3DMsoNormal><sp=
an style=3D'font-size:10.0pt;font-family:"Malgun Gothic"'><o:p>&nbsp;</o:=
p></span></p><p class=3DMsoNormal><span style=3D'font-size:10.0pt;font-fa=
mily:"Malgun Gothic"'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal><s=
pan style=3D'font-size:10.0pt;font-family:"Malgun Gothic"'><o:p>&nbsp;</o=
:p></span></p><p class=3DMsoNormal style=3D'text-align:justify;text-justi=
fy:inter-ideograph;text-autospace:none;word-break:break-all'><span style=3D=
'color:#1F497D'>Thanks,<o:p></o:p></span></p><p class=3DMsoNormal style=3D=
'text-align:justify;text-justify:inter-ideograph;text-autospace:none;word=
-break:break-all'><span style=3D'color:#1F497D'>Seongho(Shawn)<o:p></o:p>=
</span></p><p class=3DMsoNormal><o:p>&nbsp;</o:p></p></div>
<DIV>
<HR>
</DIV>
<DIV>This email message is for the sole use of the intended recipient(s) =
and may=20
contain confidential information.&nbsp; Any unauthorized review, use, dis=
closure=20
or distribution is prohibited.&nbsp; If you are not the intended recipien=
t,=20
please contact the sender by reply email and destroy all copies of the or=
iginal=20
message. </DIV>
<DIV>
<HR>
</DIV>
<P></P>
</body></html>

--_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEEHKMAIL02nvidi_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
