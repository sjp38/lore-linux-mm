Received: by rproxy.gmail.com with SMTP id c51so108058rne
        for <linux-mm@kvack.org>; Tue, 26 Apr 2005 23:21:39 -0700 (PDT)
Message-ID: <ba835822050426232165ea3e0@mail.gmail.com>
Date: Tue, 26 Apr 2005 23:21:39 -0700
From: Gilles Pokam <gpokam@gmail.com>
Reply-To: Gilles Pokam <gpokam@gmail.com>
Subject: Question on page protection mechanism
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have a general question about page protection mechanism. For some
research purpose, I need to turn off the page protection mechanism in
Linux.
In particular, I need to do so whenever I encounter this type of
pagefault for user processes. Can I simply turn it off in the
do_page_fault function, or does this requires more modifications to
the code ?

Thank you for replying.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
