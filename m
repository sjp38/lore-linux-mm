Received: from pd3mr6so.prod.shaw.ca (pd3mr6so-qfe3.prod.shaw.ca [10.0.141.21])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JJ500C1G0FXEEB0@l-daemon> for linux-mm@kvack.org; Mon,
 04 Jun 2007 18:38:21 -0600 (MDT)
Received: from pn2ml1so.prod.shaw.ca ([10.0.121.145])
 by pd3mr6so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05 (built Sep
 5 2006)) with ESMTP id <0JJ500FA30FVEYS0@pd3mr6so.prod.shaw.ca> for
 linux-mm@kvack.org; Mon, 04 Jun 2007 18:38:21 -0600 (MDT)
Received: from [192.168.1.113] ([70.64.1.86])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JJ500BHR0FRCNK0@l-daemon> for linux-mm@kvack.org; Mon,
 04 Jun 2007 18:38:15 -0600 (MDT)
Date: Mon, 04 Jun 2007 18:38:14 -0600
From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
In-reply-to: <fa.wiSgrIhkRNkkC7Wh6Bt3BY4z7BM@ifi.uio.no>
Message-id: <4664B076.5000406@shaw.ca>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
References: <fa.UBCbBXgIW93M6j2F+d+umQ5+v9I@ifi.uio.no>
 <fa.iaekQW/Par/E6eIpnL0NjEdCUxc@ifi.uio.no>
 <fa.2BlkzuhauAATrsG1MYhPMeWMhPM@ifi.uio.no>
 <fa.o9WA1K75HxwNnBEQDyoQMfWVpiQ@ifi.uio.no>
 <fa.wiSgrIhkRNkkC7Wh6Bt3BY4z7BM@ifi.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Dave Kleikamp wrote:
> I'm on Christoph's side here.  I don't think it makes sense for any code
> to ask to allocate zero bytes of memory and expect valid memory to be
> returned.
> 
> Would a compromise be to return a pointer to some known invalid region?
> This way the kmalloc(0) call would appear successful to the caller, but
> any access to the memory would result in an exception.

I would think returning 1 as the address would work here, it's not NULL 
but any access to that page should still oops..

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
