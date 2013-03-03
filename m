Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 1C1346B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 00:01:19 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id k1so7676992oag.5
        for <linux-mm@kvack.org>; Sat, 02 Mar 2013 21:01:18 -0800 (PST)
Message-ID: <5132D918.2000009@gmail.com>
Date: Sun, 03 Mar 2013 13:01:12 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: mm: introduce new field "managed_pages" to struct zone
References: <512EF580.6000608@gmail.com>
In-Reply-To: <512EF580.6000608@gmail.com>
Content-Type: multipart/alternative;
 boundary="------------050603060800000005010502"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>, Jiang Liu <jiang.liu@huawei.com>, "linux-mm@kvack.org >> Linux Memory Management List" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>

This is a multi-part message in MIME format.
--------------050603060800000005010502
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 02/28/2013 02:13 PM, Simon Jeons wrote:
> Hi Jiang,
>
> https://patchwork.kernel.org/patch/1781291/
>
> You said that the bootmem allocator doesn't touch *highmem pages*, so 
> highmem zones' managed_pages is set to the accurate value 
> "spanned_pages - absent_pages" in function free_area_init_core() and 
> won't be updated anymore. Why it doesn't touch *highmem pages*? Could 
> you point out where you figure out this?

Yeah, why bootmem doesn't touch highmem pages? The patch is buggy. :(

--------------050603060800000005010502
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 02/28/2013 02:13 PM, Simon Jeons
      wrote:<br>
    </div>
    <blockquote cite="mid:512EF580.6000608@gmail.com" type="cite">
      <meta http-equiv="content-type" content="text/html;
        charset=ISO-8859-1">
      <meta http-equiv="content-type" content="text/html;
        charset=ISO-8859-1">
      Hi Jiang,<br>
      <br>
      <a moz-do-not-send="true"
        href="https://patchwork.kernel.org/patch/1781291/">https://patchwork.kernel.org/patch/1781291/</a><br>
      <br>
      You said that the bootmem allocator doesn't touch *highmem pages*,
      so highmem zones' managed_pages is set to the accurate value
      "spanned_pages - absent_pages" in function free_area_init_core()
      and won't be updated anymore. Why it doesn't touch *highmem
      pages*? Could you point out where you figure out this?<br>
    </blockquote>
    <br>
    Yeah, why bootmem doesn't touch highmem pages? The patch is buggy.
    :(<br>
  </body>
</html>

--------------050603060800000005010502--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
