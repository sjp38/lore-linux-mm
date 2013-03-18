Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 245B86B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 19:42:58 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id hr11so3440913vcb.31
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:42:57 -0700 (PDT)
Message-ID: <5147A68B.9030207@gmail.com>
Date: Mon, 18 Mar 2013 19:43:07 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: security: restricting access to swap
References: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
In-Reply-To: <CAA25o9RchY2AD8U30bh4H+fz6kq8bs98SUrkJUkTpbTHSGjcGA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, kosaki.motohiro@gmail.com

(3/11/13 7:57 PM), Luigi Semenzato wrote:
> Greetings linux-mmers,
> 
> before we can fully deploy zram, we must ensure it conforms to the
> Chrome OS security requirements.  In particular, we do not want to
> allow user space to read/write the swap device---not even root-owned
> processes.

Could you explain Chrome OS security requirement at first? We don't want
to guess your requirement.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
