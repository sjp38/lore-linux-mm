Received: by zproxy.gmail.com with SMTP id n1so554444nzf
        for <linux-mm@kvack.org>; Fri, 07 Apr 2006 16:23:05 -0700 (PDT)
Message-ID: <6934efce0604071623v79602f32xee2448d754fb3822@mail.gmail.com>
Date: Fri, 7 Apr 2006 16:23:05 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: get_xip_page
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

What is the "create" parameter in the get_xip_page function used for?
If create = 1, does it actually create a sector and return a pointer
to it? Under what situation is create set to 1 while calling
get_xip_page? Is there any difference for a RO file system? Is it used
for a COW?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
