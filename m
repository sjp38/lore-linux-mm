Message-ID: <2984.128.2.181.129.1074703872.squirrel@webmail.andrew.cmu.edu>
In-Reply-To: <Pine.LNX.4.53.0401211803120.3693@osdl>
References: <2276.128.2.181.129.1074700039.squirrel@webmail.andrew.cmu.edu>
    <Pine.LNX.4.53.0401211803120.3693@osdl>
Date: Wed, 21 Jan 2004 11:51:12 -0500 (EST)
Subject: Re: Doubt in do_no_page()
From: "Anand Eswaran" <aeswaran@andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: logan@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi :

    Im sorry , I should have been clearer with my question. I guess my
question is what are typical examples of vma's don't get through from
the do_no_page to the do_anonymous_page

   OR rephrased

  I would like examples of ("typical", if there are)  vma's dont have any
operations or have no nopage() routine defined on them .

  Thanks a lot for replying though.

Regards,
-----
Anand.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
