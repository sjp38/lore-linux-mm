Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD2056B008A
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 20:21:38 -0500 (EST)
Received: by wwg38 with SMTP id 38so4342503wwg.26
        for <linux-mm@kvack.org>; Thu, 24 Nov 2011 17:21:35 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 25 Nov 2011 09:21:35 +0800
Message-ID: <CAKXJSOHu+sQ1NeMsRvFyp2GYoB6g+50boUu=-QvbxxjcqgOAVA@mail.gmail.com>
Subject: Question about __zone_watermark_ok: why there is a "+ 1" in computing free_pages?
From: Wang Sheng-Hui <shhuiw@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8f3b9da554164404b284f9c2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

--e89a8f3b9da554164404b284f9c2
Content-Type: text/plain; charset=ISO-8859-1

In line 1459, we have "free_pages -= (1 << order) + 1;".
Suppose allocating one 0-order page, here we'll get
    free_pages -= 1 + 1
I wonder why there is a "+ 1"?

1448/*
1449 * Return true if free pages are above 'mark'. This takes into account
the order
1450 * of the allocation.
1451 */
1452static bool __zone_watermark_ok(struct zone *z, int order, unsigned
long mark,
1453                      int classzone_idx, int alloc_flags, long
free_pages)
1454{
1455        /* free_pages my go negative - that's OK */
1456        long min = mark;
1457        int o;
1458
1459        free_pages -= (1 << order) + 1;
1460        if (alloc_flags & ALLOC_HIGH)
1461                min -= min / 2;
1462        if (alloc_flags & ALLOC_HARDER)
1463                min -= min / 4;
1464
1465        if (free_pages <= min + z->lowmem_reserve[classzone_idx])
1466                return false;
1467        for (o = 0; o < order; o++) {
1468                /* At the next order, this order's pages become
unavailable */
1469                free_pages -= z->free_area[o].nr_free << o;
1470
1471                /* Require fewer higher order pages to be free */
1472                min >>= 1;
1473
1474                if (free_pages <= min)
1475                        return false;
1476        }
1477        return true;
1478}

--e89a8f3b9da554164404b284f9c2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

In line 1459, we have &quot;free_pages -=3D (1 &lt;&lt; order) + 1;&quot;.<=
br>Suppose allocating one 0-order page, here we&#39;ll get <br>=A0=A0=A0 fr=
ee_pages -=3D 1 + 1<br>I wonder why there is a &quot;+ 1&quot;?<br><br>1448=
/*<br>1449 * Return true if free pages are above &#39;mark&#39;. This takes=
 into account the order<br>
1450 * of the allocation.<br>1451 */<br>1452static bool __zone_watermark_ok=
(struct zone *z, int order, unsigned long mark,<br>1453=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 int classzone_idx, int alloc_=
flags, long free_pages)<br>1454{<br>1455=A0=A0=A0=A0=A0=A0=A0 /* free_pages=
 my go negative - that&#39;s OK */<br>
1456=A0=A0=A0=A0=A0=A0=A0 long min =3D mark;<br>1457=A0=A0=A0=A0=A0=A0=A0 i=
nt o;<br>1458<br>1459=A0=A0=A0=A0=A0=A0=A0 free_pages -=3D (1 &lt;&lt; orde=
r) + 1;<br>1460=A0=A0=A0=A0=A0=A0=A0 if (alloc_flags &amp; ALLOC_HIGH)<br>1=
461=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 min -=3D min / 2;<br>1462=
=A0=A0=A0=A0=A0=A0=A0 if (alloc_flags &amp; ALLOC_HARDER)<br>
1463=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 min -=3D min / 4;<br>1464=
<br>1465=A0=A0=A0=A0=A0=A0=A0 if (free_pages &lt;=3D min + z-&gt;lowmem_res=
erve[classzone_idx])<br>1466=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 r=
eturn false;<br>1467=A0=A0=A0=A0=A0=A0=A0 for (o =3D 0; o &lt; order; o++) =
{<br>1468=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* At the next order=
, this order&#39;s pages become unavailable */<br>
1469=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 free_pages -=3D z-&gt;fre=
e_area[o].nr_free &lt;&lt; o;<br>1470<br>1471=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 /* Require fewer higher order pages to be free */<br>1472=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 min &gt;&gt;=3D 1;<br>1473<br=
>1474=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (free_pages &lt;=3D m=
in)<br>
1475=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 r=
eturn false;<br>1476=A0=A0=A0=A0=A0=A0=A0 }<br>1477=A0=A0=A0=A0=A0=A0=A0 re=
turn true;<br>1478}<br><br><br>

--e89a8f3b9da554164404b284f9c2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
