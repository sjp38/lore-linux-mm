Date: 14 Jan 2002 11:51:10 -0000
Message-ID: <20020114115110.29156.qmail@mailweb11.rediffmail.com>
MIME-Version: 1.0
From: "Amey Inamdar" <iamey@rediffmail.com>
Reply-To: "Amey Inamdar" <iamey@rediffmail.com>
Subject: Locking the pages after vmalloc
Content-type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
    I am vmallocating the pages. It is giving me contiguous virtual memory region. If i want to lock all the pages allocated in that region, is there any standard way to lock them? Or do i have to get each pte and then converting it to page *, lock the pages individually?
 Thanks in anticipation.

- Amey 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
