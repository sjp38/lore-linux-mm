Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C086D6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 15:40:09 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id c201so3024709wme.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 12:40:09 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id y127si14412711wmy.71.2015.12.09.12.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 12:40:08 -0800 (PST)
Received: by wmec201 with SMTP id c201so90816459wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 12:40:08 -0800 (PST)
Received: from [192.168.0.12] ([94.4.235.180])
        by smtp.gmail.com with ESMTPSA id w6sm9295367wjy.31.2015.12.09.12.40.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 12:40:06 -0800 (PST)
From: allan mcaleavy <allan.mcaleavy@gmail.com>
Content-Type: multipart/alternative; boundary="Apple-Mail=_100CF241-8BA2-455E-B869-1BA1672F0407"
Subject: tracing linux page cache usage.
Message-Id: <139BE42D-F635-46A0-B7E4-216F9ADF6137@gmail.com>
Date: Wed, 9 Dec 2015 20:40:04 +0000
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--Apple-Mail=_100CF241-8BA2-455E-B869-1BA1672F0407
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi Folks,

I am working on a rewrite of Brendan Greggs original cachestat (ftrace) =
script into bcc. What I was looking for was a steer in the right =
direction for what functions to trace. At present I trace the following.=20=


add_to_page_cache_lru
account_page_dirtied
mark_page_accessed
mark_buffer_dirty

Where total =3D (mark_page_accessed - mark_buffer_dirty) & misses =3D =
(add_to_page_cache_lru - account_page_dirtied), from this I then work =
out the hit ratio etc. Is there any other key functions I should be =
tracing?

Thanks
Allan=20=

--Apple-Mail=_100CF241-8BA2-455E-B869-1BA1672F0407
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><font face=3D"Menlo" class=3D"">Hi Folks,</font><div =
class=3D""><font face=3D"Menlo" class=3D""><br =
class=3D""></font></div><div class=3D""><font face=3D"Menlo" class=3D"">I =
am working on a rewrite of Brendan Greggs original cachestat (ftrace) =
script into bcc. What I was looking for was a steer in the right =
direction for what functions to trace. At present I trace the =
following.&nbsp;</font></div><div class=3D""><font face=3D"Menlo" =
class=3D""><br class=3D""></font></div><div class=3D""><font =
face=3D"Menlo" class=3D"">add_to_page_cache_lru</font></div><div =
class=3D""><div style=3D"margin: 0px; line-height: normal;" =
class=3D""><span style=3D"font-family: Menlo;" =
class=3D"">account_page_dirtied</span></div><div style=3D"margin: 0px; =
line-height: normal;" class=3D""><font face=3D"Menlo" =
class=3D"">mark_page_accessed</font></div><div style=3D"margin: 0px; =
line-height: normal;" class=3D""><span style=3D"font-family: Menlo;" =
class=3D"">mark_buffer_dirty</span></div><div style=3D"margin: 0px; =
line-height: normal;" class=3D""><font face=3D"Menlo" class=3D""><br =
class=3D""></font></div></div><div style=3D"margin: 0px; line-height: =
normal;" class=3D""><font face=3D"Menlo" class=3D"">Where total =3D =
(mark_page_accessed - mark_buffer_dirty) &amp; misses =3D =
(add_to_page_cache_lru - account_page_dirtied), from this I then work =
out the hit ratio etc. Is there any other key functions I should be =
tracing?</font></div><div style=3D"margin: 0px; line-height: normal;" =
class=3D""><font face=3D"Menlo" class=3D""><br =
class=3D""></font></div><div style=3D"margin: 0px; line-height: normal;" =
class=3D""><font face=3D"Menlo" class=3D"">Thanks</font></div><div =
style=3D"margin: 0px; line-height: normal;" class=3D""><font =
face=3D"Menlo" class=3D"">Allan&nbsp;</font></div></body></html>=

--Apple-Mail=_100CF241-8BA2-455E-B869-1BA1672F0407--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
