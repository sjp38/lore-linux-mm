Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2E68C6B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 03:46:06 -0400 (EDT)
Received: by mail-da0-f45.google.com with SMTP id v40so1480712dad.32
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 00:46:05 -0700 (PDT)
Message-ID: <515E8137.8050709@gmail.com>
Date: Fri, 05 Apr 2013 15:45:59 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: mm, thp: fix mapped pages avoiding unevictable list on mlock
Content-Type: multipart/alternative;
 boundary="------------000500090300060005060807"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------000500090300060005060807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

http://marc.info/?l=linux-mm&m=134810397323814&w=2

	#define MAP_SIZE	(4 << 30)	/* 4GB */

	void *ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE,
			 MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	mlock(ptr, MAP_SIZE);

		$ grep -E "Unevictable|Inactive\(anon" /proc/meminfo
		Inactive(anon):     6304 kB
		Unevictable:     4213924 kB

These pages are allocated in mlock path(gup), correct? If the answer is yes,follow_page also will not set these pages unevictable, is it? Then how you get these pages unevictable?



	munlock(ptr, MAP_SIZE);

		Inactive(anon):  4186252 kB
		Unevictable:       19652 kB

	mlock(ptr, MAP_SIZE);

		Inactive(anon):  4198556 kB
		Unevictable:       21684 kB



--------------000500090300060005060807
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    Hi David,<br>
    <br>
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <a href="http://marc.info/?l=linux-mm&amp;m=134810397323814&amp;w=2">http://marc.info/?l=linux-mm&amp;m=134810397323814&amp;w=2</a><br>
    <br>
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <pre style="color: rgb(0, 0, 0); font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;">	#define MAP_SIZE	(4 &lt;&lt; 30)	/* 4GB */

	void *ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE,
			 MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	mlock(ptr, MAP_SIZE);

		$ grep -E "Unevictable|Inactive\(anon" /proc/meminfo
		Inactive(anon):     6304 kB
		Unevictable:     4213924 kB                          

These pages are allocated in mlock path(gup), correct? If the answer is yes, <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">follow_page also will not set these pages unevictable, is it? Then how you get these pages unevictable?<pre style="color: rgb(0, 0, 0); font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;"></pre>

	munlock(ptr, MAP_SIZE);

		Inactive(anon):  4186252 kB
		Unevictable:       19652 kB

	mlock(ptr, MAP_SIZE);

		Inactive(anon):  4198556 kB
		Unevictable:       21684 kB</pre>
    <br>
  </body>
</html>

--------------000500090300060005060807--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
