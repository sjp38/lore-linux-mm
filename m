Date: Wed, 21 Jun 2000 14:57:52 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <200006211956.MAA60703@google.engr.sgi.com>
References: <20000621195525Z131176-21000+55@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 02:48:56 PM
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-Id: <20000621200418Z131176-21004+46@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
Jun 2000 12:56:12 -0700 (PDT)


> This is a left over from the days when we had a few more __GFP_ flags,
> but that has been cleaned up now, so NR_GFPINDEX can go down. 

Cool.  I'm glad to see that my questions wasn't stupid :-)

>Be aware 
> of any cache footprint issues though.

Ok, you just lost me.  What's a "cache footprint"?




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
