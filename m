Date: Thu, 05 Sep 2002 12:59:12 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: 4MB of physical contiguous memory allocation in Linux
Message-ID: <152710000.1031255952@flay>
In-Reply-To: <150940000.1031255679@flay>
References: <20020905194735.79408.qmail@web14504.mail.yahoo.com> <150940000.1031255679@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: vyas niranjan <vyas_nir@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>    I am writing a driver whereI am trying to allocate
>> 4MB of Physical contiguous memory. Using
>> __get_free_pages, I can allocate maximum of 512 pages
>> in Linux. Is there any way of allocating 4MB of
>> Physical contiguous memory in Linux??
> 
> If MAX_ORDER is 10, which it is by default, I think, you should
> be able to get 2^10 = 1024 pages = 4Mb. What happens if you
> do an order 10 allocation? Or turn MAX_ORDER up a little, and
> see what happens ...

Hmmm .... looking at a little of the code, seems like MAX_ORDER is
just really badly named, and it's the maximum order + 1. 
Turn it to 11 ... that should fix it.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
