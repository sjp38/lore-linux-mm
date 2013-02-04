Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 3847E6B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 05:34:56 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id dq12so4463198wgb.0
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 02:34:54 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 4 Feb 2013 18:34:54 +0800
Message-ID: <CAFNq8R5w7qwJ2j9VQXfw_ALZKWu_ZYaMkbd3owL5N9VOTeTVAQ@mail.gmail.com>
Subject: Qestion about page->_count and page reclaim
From: Li Haifeng <omycle@gmail.com>
Content-Type: multipart/alternative; boundary=089e0122f170d027e704d4e3a4e9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--089e0122f170d027e704d4e3a4e9
Content-Type: text/plain; charset=ISO-8859-1

Hi, all in kernel.

The page->_count is the page frame's usage count.
When page is allocated, the page will be refcounted, and page->_cout will
be set 1.

After be allocated from buddy system, the page will be used by process.
 get_page and put_page/put_page_testzero will used in pairs. is it right?

When the page is reclaimed to buddy system, the page->_count should be 0.
However, Because the initialization of page->_count is 1, get_page() and
put_page() is called in pairs, I coufused how page->_count will be 0?

Thanks.

--089e0122f170d027e704d4e3a4e9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span style=3D"color:rgb(0,0,0);font-family:arial,sans-ser=
if;font-size:14px">Hi, all in kernel.</span><div style=3D"color:rgb(0,0,0);=
font-family:arial,sans-serif;font-size:14px"><br></div><div style=3D"color:=
rgb(0,0,0);font-family:arial,sans-serif;font-size:14px">
The page-&gt;_count is the page frame&#39;s usage count.</div><div style=3D=
"color:rgb(0,0,0);font-family:arial,sans-serif;font-size:14px">When page is=
 allocated, the page will be refcounted, and page-&gt;_cout will be set 1.<=
/div>
<div style=3D"color:rgb(0,0,0);font-family:arial,sans-serif;font-size:14px"=
><br></div><div style=3D"color:rgb(0,0,0);font-family:arial,sans-serif;font=
-size:14px">After be allocated from buddy system, the page will be used by =
process. =A0get_page and put_page/put_page_testzero will used in pairs. is =
it right?</div>
<div style=3D"color:rgb(0,0,0);font-family:arial,sans-serif;font-size:14px"=
><br></div><div style=3D"color:rgb(0,0,0);font-family:arial,sans-serif;font=
-size:14px">When the page is reclaimed to buddy system, the page-&gt;_count=
 should be 0. However, Because the initialization of page-&gt;_count is 1, =
get_page() and put_page() is called in pairs, I coufused how page-&gt;_coun=
t will be 0? =A0=A0</div>
<div style=3D"color:rgb(0,0,0);font-family:arial,sans-serif;font-size:14px"=
><br></div><div style=3D"color:rgb(0,0,0);font-family:arial,sans-serif;font=
-size:14px">Thanks.</div></div>

--089e0122f170d027e704d4e3a4e9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
