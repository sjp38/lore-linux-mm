Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E932B6B0022
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 01:13:25 -0500 (EST)
Received: by mail-ia0-f178.google.com with SMTP id y26so1213139iab.37
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 22:13:25 -0800 (PST)
Message-ID: <512EF580.6000608@gmail.com>
Date: Thu, 28 Feb 2013 14:13:20 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: mm: introduce new field "managed_pages" to struct zone
Content-Type: multipart/alternative;
 boundary="------------030107020007060906080805"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>, Jiang Liu <jiang.liu@huawei.com>
Cc: "linux-mm@kvack.org >> Linux Memory Management List" <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------030107020007060906080805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jiang,

https://patchwork.kernel.org/patch/1781291/

You said that the bootmem allocator doesn't touch *highmem pages*, so 
highmem zones' managed_pages is set to the accurate value "spanned_pages 
- absent_pages" in function free_area_init_core() and won't be updated 
anymore. Why it doesn't touch *highmem pages*? Could you point out where 
you figure out this?

--------------030107020007060906080805
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    Hi Jiang,<br>
    <br>
    <a href="https://patchwork.kernel.org/patch/1781291/">https://patchwork.kernel.org/patch/1781291/</a><br>
    <br>
    You said that the bootmem allocator doesn't touch *highmem pages*,
    so highmem zones' managed_pages is set to the accurate value
    "spanned_pages - absent_pages" in function free_area_init_core() and
    won't be updated anymore. Why it doesn't touch *highmem pages*?
    Could you point out where you figure out this?<br>
  </body>
</html>

--------------030107020007060906080805--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
