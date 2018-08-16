Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30CAE6B0005
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 20:10:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g12-v6so1610506plo.1
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 17:10:47 -0700 (PDT)
Received: from smtp.tom.com (smtprz15.163.net. [106.3.154.248])
        by mx.google.com with ESMTPS id x9-v6si20260921plo.377.2018.08.15.17.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 17:10:45 -0700 (PDT)
Received: from antispam2.tom.com (unknown [172.25.16.56])
	by freemail02.tom.com (Postfix) with ESMTP id A2AA5B00D48
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 08:10:42 +0800 (CST)
Received: from antispam2.tom.com (antispam2.tom.com [127.0.0.1])
	by antispam2.tom.com (Postfix) with ESMTP id 9D880812C8
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 08:10:42 +0800 (CST)
Received: from antispam2.tom.com ([127.0.0.1])
	by antispam2.tom.com (antispam2.tom.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TmK_1g9hhXxC for <linux-mm@kvack.org>;
	Thu, 16 Aug 2018 08:10:42 +0800 (CST)
Date: Thu, 16 Aug 2018 08:10:42 +0800 (CST)
From: =?UTF-8?B?emhvdXhpYW5yb25n?= <zhouxianrong@tom.com>
Message-ID: <1784999539.213028.1534378242020.JavaMail.root@rz-web2>
In-Reply-To: <20180814002416.GA34280@rodete-desktop-imager.corp.google.com>
References: <20180810002817.2667-1-zhouxianrong@tom.com>
 <20180813060549.GB64836@rodete-desktop-imager.corp.google.com>
 <20180813105536.GA435@jagdpanzerIV> <20180814002416.GA34280@rodete-desktop-imager.corp.google.com>
Subject: =?UTF-8?B?UmU6UmU6IFtQQVRDSF0genNtYWxsb2M6IGZpeCBsaW5raW5nIGJ1ZyBpbiBpbml0X3pzcGFnZQ==?=
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_213026_1426593989.1534378242018"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?TWluY2hhbiBLaW0=?= <minchan@kernel.org>, sergey.senozhatsky.work@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, zhouxianrong@huawei.com, vbabka@suse.cz, yudongbin@hisilicon.com

------=_Part_213026_1426593989.1534378242018
Content-Type: multipart/alternative;
	boundary="----=_Part_213027_110254368.1534378242018"

------=_Part_213027_110254368.1534378242018
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: quoted-printable

H<span labeltype=3D"transpond"><minchan kernel=3D"" org=3D"">i:<br /><br />=
&nbsp; I am sorry so later for replying this message due to something.<br /=
><br />This is the backtrace edited by me we met.<br /><br />[pid:3471,cpu4=
,thread-3]------------[ cut here ]------------<br />[pid:3471,cpu4,thread-3=
]kernel bug at ../../../../../../mm/zsmalloc.c:1455!<br />[pid:3471,cpu4,th=
read-3]internal error: oops - bug: 0 [#1] preempt smp<br />[pid:3471,cpu4,t=
hread-3]modules linked in:<br />[pid:3471,cpu4,thread-3]cpu: 4 pid: 3471 co=
mm: thread-3 tainted: g&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; w&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; 4.9.84 #1<br />[pid:3471,cpu4,thread-3]tgid: 7=
15 comm: proc-a<br />[pid:3471,cpu4,thread-3]task: ffffffcc83ba1d00 task.st=
ack: ffffffcad99b0000<br />[pid:3471,cpu4,thread-3]pc is at zs_map_object+0=
x1e0/0x1f0<br />[pid:3471,cpu4,thread-3]lr is at zs_map_object+0x9c/0x1f0<b=
r />[pid:3471,cpu4,thread-3]pc : [] lr : [] pstate: 20000145<br />[pid:3471=
,cpu4,thread-3]sp : ffffffcad99b3530<br />[pid:3471,cpu4,thread-3]x29: ffff=
ffcad99b3530 x28: ffffffcc97533c40<br />[pid:3471,cpu4,thread-3]x27: ffffff=
cc974dd720 x26: ffffffcad99b0000<br />[pid:3471,cpu4,thread-3]x25: 00000000=
01fa9f80 x24: 0000000000000002<br />[pid:3471,cpu4,thread-3]x23: ffffff89c3=
a27000 x22: ffffff89c30e6000<br />[pid:3471,cpu4,thread-3]x21: ffffff89c354=
f000 x20: ffffff89c3234720<br />[pid:3471,cpu4,thread-3]x19: 0000000000000f=
90 x18: 0000000000000008<br />[pid:3471,cpu4,thread-3]x17: 00000000bbb877ff=
 x16: 00000000ffdba560<br />[pid:3471,cpu4,thread-3]x15: ffffffcaeab13ff5 x=
14: 000000009e3779b1<br />[pid:3471,cpu4,thread-3]x13: 0000000000000ff4 x12=
: ffffffcaeab13fd9<br />[pid:3471,cpu4,thread-3]x11: ffffffcaeab13ffa x10: =
ffffffcaeab13ff8<br />[pid:3471,cpu4,thread-3]x9 : ffffffca8cc201b8 x8 : ff=
ffffca8cc20190<br />[pid:3471,cpu4,thread-3]x7 : 000000000000008e x6 : 0000=
00000000009b<br />[pid:3471,cpu4,thread-3]x5 : 0000000000000000 x4 : 000000=
0000000001<br />[pid:3471,cpu4,thread-3]x3 : 00000042d42a9000 x2 : 00000000=
000009d0<br />[pid:3471,cpu4,thread-3]x1 : ffffffcc994ddbc0 x0 : 0000000000=
000000<br /><br />[pid:3471,cpu4,thread-3] zs_map_object+0x1e0/0x1f0<br />[=
pid:3471,cpu4,thread-3] zs_zpool_map+0x44/0x54<br />[pid:3471,cpu4,thread-3=
] zpool_map_handle+0x44/0x58<br />[pid:3471,cpu4,thread-3] zram_bvec_write+=
0x22c/0x76c<br />[pid:3471,cpu4,thread-3] zram_bvec_rw+0x288/0x488<br />[pi=
d:3471,cpu4,thread-3] zram_rw_page+0x124/0x1a4<br />[pid:3471,cpu4,thread-3=
] bdev_write_page+0x8c/0xd8<br />[pid:3471,cpu4,thread-3] __swap_writepage+=
0x1c0/0x3a8<br />[pid:3471,cpu4,thread-3] swap_writepage+0x3c/0x64<br />[pi=
d:3471,cpu4,thread-3] shrink_page_list+0x844/0xd84<br />[pid:3471,cpu4,thre=
ad-3] reclaim_pages_from_list+0xf4/0x1bc<br />[pid:3471,cpu4,thread-3] recl=
aim_pte_range+0x208/0x2a0<br />[pid:3471,cpu4,thread-3] walk_pgd_range+0xe8=
/0x238<br />[pid:3471,cpu4,thread-3] walk_page_range+0x7c/0x164<br />[pid:3=
471,cpu4,thread-3] reclaim_write+0x208/0x608<br />[pid:3471,cpu4,thread-3] =
__vfs_write+0x50/0x88<br />[pid:3471,cpu4,thread-3] vfs_write+0xbc/0x2b0<br=
 />[pid:3471,cpu4,thread-3] sys_write+0x60/0xc4<br />[pid:3471,cpu4,thread-=
3] el0_svc_naked+0x34/0x38<br />[pid:3471,cpu4,thread-3]code: 17ffffdd d421=
0000 97ffff1f 97ffff83 (d4210000)<br />[pid:3471,cpu4,thread-3]---[ end tra=
ce 652caafc4c4b6d06 ]--- <br /></minchan></span><blockquote style=3D"paddin=
g-left:1ex;margin:0px 0px 0px 0.8ex;border-left:#ccc 1px solid"><pre>Hi Ser=
gey,

On Mon, Aug 13, 2018 at 07:55:36PM +0900, Sergey Senozhatsky wrote:
&gt; On (08/13/18 15:05), Minchan Kim wrote:
&gt; &gt; &gt; From: zhouxianrong <zhouxianrong huawei=3D"" com=3D"">
&gt; &gt; &gt;=20
&gt; &gt; &gt; The last partial object in last subpage of zspage should not=
 be linked
&gt; &gt; &gt; in allocation list. Otherwise it could trigger BUG_ON explic=
itly at
&gt; &gt; &gt; function zs_map_object. But it happened rarely.
&gt; &gt;=20
&gt; &gt; Could you be more specific? What case did you see the problem?
&gt; &gt; Is it a real problem or one founded by review?
&gt; [..]
&gt; &gt; &gt; Signed-off-by: zhouxianrong <zhouxianrong huawei=3D"" com=3D=
"">
&gt; &gt; &gt; ---
&gt; &gt; &gt;  mm/zsmalloc.c | 2 ++
&gt; &gt; &gt;  1 file changed, 2 insertions(+)
&gt; &gt; &gt;=20
&gt; &gt; &gt; diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
&gt; &gt; &gt; index 8d87e973a4f5..24dd8da0aa59 100644
&gt; &gt; &gt; --- a/mm/zsmalloc.c
&gt; &gt; &gt; +++ b/mm/zsmalloc.c
&gt; &gt; &gt; @@ -1040,6 +1040,8 @@ static void init_zspage(struct size_cl=
ass *class, struct zspage *zspage)
&gt; &gt; &gt;  =09=09=09 * Reset OBJ_TAG_BITS bit to last link to tell
&gt; &gt; &gt;  =09=09=09 * whether it's allocated object or not.
&gt; &gt; &gt;  =09=09=09 */
&gt; &gt; &gt; +=09=09=09if (off &gt; PAGE_SIZE)
&gt; &gt; &gt; +=09=09=09=09link -=3D class-&gt;size / sizeof(*link);
&gt; &gt; &gt;  =09=09=09link-&gt;next =3D -1UL &lt;&lt; OBJ_TAG_BITS;
&gt; &gt; &gt;  =09=09}
&gt; &gt; &gt;  =09=09kunmap_atomic(vaddr);
&gt;=20
&gt; Hmm. This can be a real issue. Unless I'm missing something.
&gt;=20
&gt; So... I might be wrong, but the way I see the bug report is:
&gt;=20
&gt; When we link objects during zspage init, we do the following:
&gt;=20
&gt; =09while ((off +=3D class-&gt;size) &lt; PAGE_SIZE) {
&gt; =09=09link-&gt;next =3D freeobj++ &lt;&lt; OBJ_TAG_BITS;
&gt; =09=09link +=3D class-&gt;size / sizeof(*link);
&gt; =09}
&gt;=20
&gt; Note that we increment the link first, link +=3D class-&gt;size / size=
of(*link),
&gt; and check for the offset only afterwards. So by the time we break out =
of
&gt; the while-loop the link *might* point to the partial object which star=
ts at
&gt; the last page of zspage, but *never* ends, because we don't have next_=
page
&gt; in current zspage. So that's why that object should not be linked in,
&gt; because it's not a valid allocates object - we simply don't have space
&gt; for it anymore.
&gt;=20
&gt; zspage [      page 1     ][      page 2      ]
&gt;         ...............................link
&gt; =09                                   [..###]
&gt;=20
&gt; therefore the last object must be &quot;link - 1&quot; for such cases.
&gt;=20
&gt; I think, the following change can also do the trick:
&gt;=20
&gt; =09while ((off + class-&gt;size) &lt; PAGE_SIZE) {
&gt; =09=09link-&gt;next =3D freeobj++ &lt;&lt; OBJ_TAG_BITS;
&gt; =09=09link +=3D class-&gt;size / sizeof(*link);
&gt; =09=09off +=3D class-&gt;size;
&gt; =09}
&gt;=20
&gt; Once again, I might be wrong on this.
&gt; Any thoughts?

If we want a refactoring, I'm not against but description said it tiggered
BUG_ON on zs_map_object rarely. That means it should be stable material
and need more description to understand. Please be more specific with
some example. The reason I'm hesitating is zsmalloc moves ZS_FULL group
when the zspage-&gt;inuse is equal to class-&gt;objs_per_zspage so I though=
t
it shouldn't allocate last partial object.

Thanks.
</zhouxianrong></zhouxianrong></pre></blockquote><div style=3D"height:30px;=
"></div><div style=3D"height:2px;width:298px;border-bottom:solid 2px #e5e5e=
5"></div><div style=3D"height:20px;"></div><a target=3D"_blank" style=3D"ba=
ckground-image:url(http://r.g.tom.com/kwap/r/app/other/suixinyou.png);backg=
round-repeat:no-repeat;background-position:left center;font-size:14px;backg=
round-size: 20px;height: 39px;line-height: 39px;padding-left: 25px;display:=
block;color:#333333;text-decoration: none;" href=3D"http://mail.tom.com/web=
mail-static/welcomesxy.html"  onmouseover=3D"this.style.cssText=3D'backgrou=
nd-image:url(http://r.g.tom.com/kwap/r/app/other/suixinyou.png);background-=
repeat:no-repeat;background-position:left center;font-size:14px;background-=
size: 20px;height: 39px;line-height: 39px;padding-left: 27px;display:block;=
color:#4c4c4c; text-decoration:underline;'" onmouseout=3D"this.style.cssTex=
t=3D'background-image:url(http://r.g.tom.com/kwap/r/app/other/suixinyou.png=
);background-repeat:no-repeat;background-position:left center;font-size:14p=
x;background-size: 20px;height: 39px;line-height: 39px;padding-left: 27px;d=
isplay:block;color:#4c4c4c;text-decoration:none'">=E9=9A=8F=E5=BF=83=E9=82=
=AE-=E5=9C=A8=E5=BE=AE=E4=BF=A1=E9=87=8C=E6=94=B6=E5=8F=91=E9=82=AE=E4=BB=
=B6=EF=BC=8C=E5=8F=8A=E6=97=B6=E7=9C=81=E7=94=B5=E5=8F=88=E5=AE=89=E5=BF=83=
</a>
------=_Part_213027_110254368.1534378242018
Content-Type: text/html;charset=utf-8
Content-Transfer-Encoding: quoted-printable

H<span labeltype=3D"transpond"><minchan kernel=3D"" org=3D"">i:<br /><br />=
&nbsp; I am sorry so later for replying this message due to something.<br /=
><br />This is the backtrace edited by me we met.<br /><br />[pid:3471,cpu4=
,thread-3]------------[ cut here ]------------<br />[pid:3471,cpu4,thread-3=
]kernel bug at ../../../../../../mm/zsmalloc.c:1455!<br />[pid:3471,cpu4,th=
read-3]internal error: oops - bug: 0 [#1] preempt smp<br />[pid:3471,cpu4,t=
hread-3]modules linked in:<br />[pid:3471,cpu4,thread-3]cpu: 4 pid: 3471 co=
mm: thread-3 tainted: g&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; w&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; 4.9.84 #1<br />[pid:3471,cpu4,thread-3]tgid: 7=
15 comm: proc-a<br />[pid:3471,cpu4,thread-3]task: ffffffcc83ba1d00 task.st=
ack: ffffffcad99b0000<br />[pid:3471,cpu4,thread-3]pc is at zs_map_object+0=
x1e0/0x1f0<br />[pid:3471,cpu4,thread-3]lr is at zs_map_object+0x9c/0x1f0<b=
r />[pid:3471,cpu4,thread-3]pc : [] lr : [] pstate: 20000145<br />[pid:3471=
,cpu4,thread-3]sp : ffffffcad99b3530<br />[pid:3471,cpu4,thread-3]x29: ffff=
ffcad99b3530 x28: ffffffcc97533c40<br />[pid:3471,cpu4,thread-3]x27: ffffff=
cc974dd720 x26: ffffffcad99b0000<br />[pid:3471,cpu4,thread-3]x25: 00000000=
01fa9f80 x24: 0000000000000002<br />[pid:3471,cpu4,thread-3]x23: ffffff89c3=
a27000 x22: ffffff89c30e6000<br />[pid:3471,cpu4,thread-3]x21: ffffff89c354=
f000 x20: ffffff89c3234720<br />[pid:3471,cpu4,thread-3]x19: 0000000000000f=
90 x18: 0000000000000008<br />[pid:3471,cpu4,thread-3]x17: 00000000bbb877ff=
 x16: 00000000ffdba560<br />[pid:3471,cpu4,thread-3]x15: ffffffcaeab13ff5 x=
14: 000000009e3779b1<br />[pid:3471,cpu4,thread-3]x13: 0000000000000ff4 x12=
: ffffffcaeab13fd9<br />[pid:3471,cpu4,thread-3]x11: ffffffcaeab13ffa x10: =
ffffffcaeab13ff8<br />[pid:3471,cpu4,thread-3]x9 : ffffffca8cc201b8 x8 : ff=
ffffca8cc20190<br />[pid:3471,cpu4,thread-3]x7 : 000000000000008e x6 : 0000=
00000000009b<br />[pid:3471,cpu4,thread-3]x5 : 0000000000000000 x4 : 000000=
0000000001<br />[pid:3471,cpu4,thread-3]x3 : 00000042d42a9000 x2 : 00000000=
000009d0<br />[pid:3471,cpu4,thread-3]x1 : ffffffcc994ddbc0 x0 : 0000000000=
000000<br /><br />[pid:3471,cpu4,thread-3] zs_map_object+0x1e0/0x1f0<br />[=
pid:3471,cpu4,thread-3] zs_zpool_map+0x44/0x54<br />[pid:3471,cpu4,thread-3=
] zpool_map_handle+0x44/0x58<br />[pid:3471,cpu4,thread-3] zram_bvec_write+=
0x22c/0x76c<br />[pid:3471,cpu4,thread-3] zram_bvec_rw+0x288/0x488<br />[pi=
d:3471,cpu4,thread-3] zram_rw_page+0x124/0x1a4<br />[pid:3471,cpu4,thread-3=
] bdev_write_page+0x8c/0xd8<br />[pid:3471,cpu4,thread-3] __swap_writepage+=
0x1c0/0x3a8<br />[pid:3471,cpu4,thread-3] swap_writepage+0x3c/0x64<br />[pi=
d:3471,cpu4,thread-3] shrink_page_list+0x844/0xd84<br />[pid:3471,cpu4,thre=
ad-3] reclaim_pages_from_list+0xf4/0x1bc<br />[pid:3471,cpu4,thread-3] recl=
aim_pte_range+0x208/0x2a0<br />[pid:3471,cpu4,thread-3] walk_pgd_range+0xe8=
/0x238<br />[pid:3471,cpu4,thread-3] walk_page_range+0x7c/0x164<br />[pid:3=
471,cpu4,thread-3] reclaim_write+0x208/0x608<br />[pid:3471,cpu4,thread-3] =
__vfs_write+0x50/0x88<br />[pid:3471,cpu4,thread-3] vfs_write+0xbc/0x2b0<br=
 />[pid:3471,cpu4,thread-3] sys_write+0x60/0xc4<br />[pid:3471,cpu4,thread-=
3] el0_svc_naked+0x34/0x38<br />[pid:3471,cpu4,thread-3]code: 17ffffdd d421=
0000 97ffff1f 97ffff83 (d4210000)<br />[pid:3471,cpu4,thread-3]---[ end tra=
ce 652caafc4c4b6d06 ]--- <br /></minchan></span><blockquote style=3D"paddin=
g-left:1ex;margin:0px 0px 0px 0.8ex;border-left:#ccc 1px solid"><pre>Hi Ser=
gey,

On Mon, Aug 13, 2018 at 07:55:36PM +0900, Sergey Senozhatsky wrote:
&gt; On (08/13/18 15:05), Minchan Kim wrote:
&gt; &gt; &gt; From: zhouxianrong <zhouxianrong huawei=3D"" com=3D"">
&gt; &gt; &gt;=20
&gt; &gt; &gt; The last partial object in last subpage of zspage should not=
 be linked
&gt; &gt; &gt; in allocation list. Otherwise it could trigger BUG_ON explic=
itly at
&gt; &gt; &gt; function zs_map_object. But it happened rarely.
&gt; &gt;=20
&gt; &gt; Could you be more specific? What case did you see the problem?
&gt; &gt; Is it a real problem or one founded by review?
&gt; [..]
&gt; &gt; &gt; Signed-off-by: zhouxianrong <zhouxianrong huawei=3D"" com=3D=
"">
&gt; &gt; &gt; ---
&gt; &gt; &gt;  mm/zsmalloc.c | 2 ++
&gt; &gt; &gt;  1 file changed, 2 insertions(+)
&gt; &gt; &gt;=20
&gt; &gt; &gt; diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
&gt; &gt; &gt; index 8d87e973a4f5..24dd8da0aa59 100644
&gt; &gt; &gt; --- a/mm/zsmalloc.c
&gt; &gt; &gt; +++ b/mm/zsmalloc.c
&gt; &gt; &gt; @@ -1040,6 +1040,8 @@ static void init_zspage(struct size_cl=
ass *class, struct zspage *zspage)
&gt; &gt; &gt;  =09=09=09 * Reset OBJ_TAG_BITS bit to last link to tell
&gt; &gt; &gt;  =09=09=09 * whether it's allocated object or not.
&gt; &gt; &gt;  =09=09=09 */
&gt; &gt; &gt; +=09=09=09if (off &gt; PAGE_SIZE)
&gt; &gt; &gt; +=09=09=09=09link -=3D class-&gt;size / sizeof(*link);
&gt; &gt; &gt;  =09=09=09link-&gt;next =3D -1UL &lt;&lt; OBJ_TAG_BITS;
&gt; &gt; &gt;  =09=09}
&gt; &gt; &gt;  =09=09kunmap_atomic(vaddr);
&gt;=20
&gt; Hmm. This can be a real issue. Unless I'm missing something.
&gt;=20
&gt; So... I might be wrong, but the way I see the bug report is:
&gt;=20
&gt; When we link objects during zspage init, we do the following:
&gt;=20
&gt; =09while ((off +=3D class-&gt;size) &lt; PAGE_SIZE) {
&gt; =09=09link-&gt;next =3D freeobj++ &lt;&lt; OBJ_TAG_BITS;
&gt; =09=09link +=3D class-&gt;size / sizeof(*link);
&gt; =09}
&gt;=20
&gt; Note that we increment the link first, link +=3D class-&gt;size / size=
of(*link),
&gt; and check for the offset only afterwards. So by the time we break out =
of
&gt; the while-loop the link *might* point to the partial object which star=
ts at
&gt; the last page of zspage, but *never* ends, because we don't have next_=
page
&gt; in current zspage. So that's why that object should not be linked in,
&gt; because it's not a valid allocates object - we simply don't have space
&gt; for it anymore.
&gt;=20
&gt; zspage [      page 1     ][      page 2      ]
&gt;         ...............................link
&gt; =09                                   [..###]
&gt;=20
&gt; therefore the last object must be &quot;link - 1&quot; for such cases.
&gt;=20
&gt; I think, the following change can also do the trick:
&gt;=20
&gt; =09while ((off + class-&gt;size) &lt; PAGE_SIZE) {
&gt; =09=09link-&gt;next =3D freeobj++ &lt;&lt; OBJ_TAG_BITS;
&gt; =09=09link +=3D class-&gt;size / sizeof(*link);
&gt; =09=09off +=3D class-&gt;size;
&gt; =09}
&gt;=20
&gt; Once again, I might be wrong on this.
&gt; Any thoughts?

If we want a refactoring, I'm not against but description said it tiggered
BUG_ON on zs_map_object rarely. That means it should be stable material
and need more description to understand. Please be more specific with
some example. The reason I'm hesitating is zsmalloc moves ZS_FULL group
when the zspage-&gt;inuse is equal to class-&gt;objs_per_zspage so I though=
t
it shouldn't allocate last partial object.

Thanks.
</zhouxianrong></zhouxianrong></pre></blockquote><div style=3D"height:30px;=
"></div><div style=3D"height:2px;width:298px;border-bottom:solid 2px #e5e5e=
5"></div><div style=3D"height:20px;"></div><a target=3D"_blank" style=3D"ba=
ckground-image:url(http://r.g.tom.com/kwap/r/app/other/suixinyou.png);backg=
round-repeat:no-repeat;background-position:left center;font-size:14px;backg=
round-size: 20px;height: 39px;line-height: 39px;padding-left: 25px;display:=
block;color:#333333;text-decoration: none;" href=3D"http://mail.tom.com/web=
mail-static/welcomesxy.html"  onmouseover=3D"this.style.cssText=3D'backgrou=
nd-image:url(http://r.g.tom.com/kwap/r/app/other/suixinyou.png);background-=
repeat:no-repeat;background-position:left center;font-size:14px;background-=
size: 20px;height: 39px;line-height: 39px;padding-left: 27px;display:block;=
color:#4c4c4c; text-decoration:underline;'" onmouseout=3D"this.style.cssTex=
t=3D'background-image:url(http://r.g.tom.com/kwap/r/app/other/suixinyou.png=
);background-repeat:no-repeat;background-position:left center;font-size:14p=
x;background-size: 20px;height: 39px;line-height: 39px;padding-left: 27px;d=
isplay:block;color:#4c4c4c;text-decoration:none'">=E9=9A=8F=E5=BF=83=E9=82=
=AE-=E5=9C=A8=E5=BE=AE=E4=BF=A1=E9=87=8C=E6=94=B6=E5=8F=91=E9=82=AE=E4=BB=
=B6=EF=BC=8C=E5=8F=8A=E6=97=B6=E7=9C=81=E7=94=B5=E5=8F=88=E5=AE=89=E5=BF=83=
</a>
------=_Part_213027_110254368.1534378242018--

------=_Part_213026_1426593989.1534378242018--
